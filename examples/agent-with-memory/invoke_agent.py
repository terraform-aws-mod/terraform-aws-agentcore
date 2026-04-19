import json

import boto3

client = boto3.client("bedrock-agentcore", region_name="us-east-1")
payload = json.dumps({"prompt": "Remember that my favorite color is blue. What tools do you have?"})
session_id = "test-memory-session-12345678901234567890123"

response = client.invoke_agent_runtime(
    agentRuntimeArn="<YOUR_AGENT_RUNTIME_ARN>",
    runtimeSessionId=session_id,
    payload=payload,
    qualifier="DEFAULT",
)
response_body = response["response"].read()
response_data = json.loads(response_body)
print("Agent Response:", response_data)
