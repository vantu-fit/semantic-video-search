import json
import boto3
import os
from opensearchpy import OpenSearch, RequestsHttpConnection


SAGEMAKER_ENDPOINT_NAME = os.environ.get("SAGEMAKER_ENDPOINT_NAME")
OPENSEARCH_ENDPOINT = os.environ.get("OPENSEARCH_ENDPOINT")
OPENSEARCH_INDEX = os.environ.get("INDEX_NAME")
USERNAME = os.environ.get("USERNAME")
PASSWORD = os.environ.get("PASSWORD")

if not SAGEMAKER_ENDPOINT_NAME:
    raise ValueError("SAGEMAKER_ENDPOINT_NAME is required")

if not OPENSEARCH_ENDPOINT:
    raise ValueError("OPENSEARCH_ENDPOINT is required")

if not OPENSEARCH_INDEX:
    raise ValueError("INDEX_NAME is required")

if not USERNAME:
    raise ValueError("USERNAME is required")

if not PASSWORD:
    raise ValueError("PASSWORD is required")

s3_client = boto3.client("s3")
sagemaker_runtime = boto3.client("sagemaker-runtime")
client = OpenSearch(
    hosts=[{"host": OPENSEARCH_ENDPOINT, "port": 443}],
    http_auth=(USERNAME, PASSWORD),
    use_ssl=True,
    verify_certs=True,
    connection_class=RequestsHttpConnection,
    timeout=120,
    max_retries=5,
    retry_on_timeout=True,
)


def query_index(query_vector, k=3):
    query = {
        "size": k,
        "query": {
            "knn": {
                "image_embedding": {
                    "vector": query_vector,
                    "k": k,
                }
            }
        },
    }

    response = client.search(index=OPENSEARCH_INDEX, body=query)
    return response


def lambda_handler(event, context):
    try:
        body = json.loads(event["body"])
        text = body.get("text", "")
        top_k = body.get("top_k", 3)

        if not text:
            return {
                "statusCode": 400,
                "body": json.dumps({"error": "Text field is required"}),
            }

        # Invoke SageMaker endpoint
        response_sagemaker = sagemaker_runtime.invoke_endpoint(
            EndpointName=SAGEMAKER_ENDPOINT_NAME,
            Body=json.dumps({"text": text}),
            ContentType="application/json",
        )

        response_body = json.loads(response_sagemaker["Body"].read().decode("utf-8"))
        # vector search
        query_vector = response_body["embeddings"]

        response_query = query_index(query_vector, top_k)

        # return list of matched documents
        result = []
        # {
        #     "image" : 1,
        #     "video" : "video1.mp4"
        #     "score" : 1
        # }
        response_query = response_query["hits"]["hits"]

        for hit in response_query:
            image = hit["_source"]["image"]
            video = hit["_source"]["video"]
            score = hit["_score"]
            result.append({"image": image, "video": video, "score": score})

        response = {
            "result": result,
        }

        return {"statusCode": 200, "body": json.dumps(response)}

    except Exception as e:
        print(f"Error: {e}")
        return {"statusCode": 500, "body": json.dumps({"error": str(e)})}


lambda_handler(
    {
        "body": json.dumps(
            {"text": "A video clip shows mothers taking care of children with chickenpox. Chickenpox causes blisters to appear all over the children's bodies, accompanied by uncomfortable itching.", "top_k": 5}
        )
    },
    None,
)
