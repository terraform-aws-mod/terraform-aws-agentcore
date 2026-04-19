#!/bin/bash
set -euo pipefail

# =============================================================================
# Build and push images to ECR
# Usage: ./build_image.sh --account <id> --region <region> --ecr-name <name> \
#        --tags <tag1,tag2,...> --dockerfile <path> [--context <path>] \
#        [--build-args "KEY=VALUE,KEY2=VALUE2"] [--platform <platform>] \
#        [--use-cache <true|false>] [--provenance <true|false>]
# =============================================================================

# Logging functions
log_info()    { echo "[INFO]  $(date '+%H:%M:%S') $*"; }
log_error()   { echo "[ERROR] $(date '+%H:%M:%S') $*" >&2; }
log_success() { echo "[OK]    $(date '+%H:%M:%S') $*"; }

# Default values
aws_account_id=""
aws_region_name=""
ecr_name=""
image_tags=""
dockerfile_path=""
build_args=""
context_path=""
platform="linux/arm64"
use_cache="true"
provenance="false"

# Parse named arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --account)      aws_account_id="$2"; shift 2 ;;
        --region)       aws_region_name="$2"; shift 2 ;;
        --ecr-name)     ecr_name="$2"; shift 2 ;;
        --tags)         image_tags="$2"; shift 2 ;;
        --dockerfile)   dockerfile_path="$2"; shift 2 ;;
        --build-args)   build_args="$2"; shift 2 ;;
        --context)      context_path="$2"; shift 2 ;;
        --platform)     platform="$2"; shift 2 ;;
        --use-cache)    use_cache="$2"; shift 2 ;;
        --provenance)   provenance="$2"; shift 2 ;;
        *) log_error "Unknown argument: $1"; exit 1 ;;
    esac
done

# Validate required parameters
[[ -z "$aws_account_id" ]]  && { log_error "aws_account_id is required (--account)"; exit 1; }
[[ -z "$aws_region_name" ]] && { log_error "aws_region_name is required (--region)"; exit 1; }
[[ -z "$ecr_name" ]]        && { log_error "ecr_name is required (--ecr-name)"; exit 1; }
[[ -z "$image_tags" ]]      && { log_error "image_tags is required (--tags)"; exit 1; }
[[ -z "$dockerfile_path" ]] && { log_error "dockerfile_path is required (--dockerfile)"; exit 1; }

# Default context to dockerfile directory if not provided
if [[ -z "$context_path" ]]; then
    context_path="$(dirname "$dockerfile_path")"
fi

# Parse tags into array
IFS=',' read -ra TAGS <<< "$image_tags"

log_info "Building image for ECR: ${ecr_name}"
log_info "Tags: ${image_tags}"
log_info "Dockerfile: ${dockerfile_path}"
log_info "Context: ${context_path}"
log_info "Platform: ${platform}"
log_info "Use cache: ${use_cache}"
log_info "Provenance: ${provenance}"

# Login to ECR
log_info "Logging in to ECR..."
login_error_file=$(mktemp)
if ! aws ecr get-login-password --region "$aws_region_name" | docker login -u AWS "${aws_account_id}.dkr.ecr.${aws_region_name}.amazonaws.com" --password-stdin 2> "$login_error_file"; then
    if grep -q "The specified item already exists in the keychain." "$login_error_file"; then
        log_info "ECR credentials already in keychain, continuing..."
    else
        log_error "Cannot login to ECR: $(cat "$login_error_file")"
        rm -f "$login_error_file"
        exit 1
    fi
else
    log_success "ECR login successful"
fi
rm -f "$login_error_file"

# Get latest image tag for cache
cache_from=""
cache_to=""
if [[ "$use_cache" == "true" ]]; then
    log_info "Checking for existing images to use as cache..."
    latest_image_tag=$(aws ecr describe-images --repository-name "${ecr_name}" \
        --query 'sort_by(imageDetails,& imagePushedAt)[-1].imageTags[0]' 2>/dev/null | tr -d '"' || echo "")

    if [[ -n "$latest_image_tag" ]] && [[ "$latest_image_tag" != "null" ]]; then
        log_info "Using cache from: ${ecr_name}:${latest_image_tag}"
        cache_from="--cache-from type=registry,ref=${aws_account_id}.dkr.ecr.${aws_region_name}.amazonaws.com/${ecr_name}:${latest_image_tag}"
    else
        log_info "No existing image found, building without cache"
    fi
    cache_to="--cache-to type=inline"
else
    log_info "Cache disabled, building without cache"
fi

# Build the build-args string
build_args_flags=""
if [[ -n "$build_args" ]]; then
    IFS=',' read -ra ARGS <<< "$build_args"
    for arg in "${ARGS[@]}"; do
        build_args_flags+=" --build-arg ${arg}"
    done
    log_info "Build args: ${build_args}"
fi

# Build tag flags for docker build command (multiple -t flags)
tag_flags=""
for tag in "${TAGS[@]}"; do
    tag_flags+=" -t ${aws_account_id}.dkr.ecr.${aws_region_name}.amazonaws.com/${ecr_name}:${tag}"
done

# Build the image with all tags
log_info "Building Docker image..."
log_info "docker buildx build $context_path -f ${dockerfile_path} --platform=${platform} ${tag_flags} ${build_args_flags} ${cache_from} ${cache_to} --provenance=${provenance} --push"
if ! docker buildx build "$context_path" \
    -f "${dockerfile_path}" \
    --platform="${platform}" \
    ${tag_flags} \
    ${build_args_flags} \
    ${cache_from} \
    ${cache_to} \
    --provenance="${provenance}" \
    --push; then
    log_error "Cannot build and push docker image for ${ecr_name}"
    exit 1
fi

log_success "Successfully built and pushed ${ecr_name} with tags: ${image_tags}"
