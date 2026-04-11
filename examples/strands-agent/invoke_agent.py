import boto3
import json

client = boto3.client('bedrock-agentcore', region_name='us-east-1')
payload = json.dumps({"message": "Explain machine learning in simple terms"})
# creating a dummy session id for testing. In production, you would want to generate a unique session id for each conversation to maintain context.
session_id = "test-session-123456789012345678901234567890123"

response = client.invoke_agent_runtime(
    agentRuntimeArn='arn:aws:bedrock-agentcore:us-east-1:616640453089:runtime/strands_agent_example-h8k7BVEQlx',
    runtimeSessionId=session_id, # Must be 33+ char. Every new SessionId will create a new MicroVM
    payload=payload,
    qualifier="DEFAULT" # This is Optional. When the field is not provided, Runtime will use DEFAULT endpoint
)
response_body = response['response'].read()
response_data = json.loads(response_body)
print("Agent Response:", response_data)
