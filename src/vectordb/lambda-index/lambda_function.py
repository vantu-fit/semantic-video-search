import json
import boto3
import os
import numpy
import io
from opensearchpy import OpenSearch, RequestsHttpConnection , helpers

OPENSEARCH_ENDPOINT = os.environ.get("OPENSEARCH_ENDPOINT")
OPENSEARCH_INDEX = os.environ.get("INDEX_NAME")
USERNAME = os.environ.get("USERNAME")
PASSWORD = os.environ.get("PASSWORD")

s3_client = boto3.client("s3")
client = OpenSearch(
    hosts=[{"host": OPENSEARCH_ENDPOINT, "port": 443}],
    http_auth=(USERNAME, PASSWORD),
    # http_auth=awsauth,
    use_ssl=True,
    verify_certs=True,
    connection_class=RequestsHttpConnection,
    timeout=120,
    max_retries=5,
    retry_on_timeout=True,
)

client.info()

def create_index(index):
        index_body = {
            "settings": {"index": {"knn": True}},
            "mappings": {
                "properties": {
                    "image_embedding": {
                        "type": "knn_vector",
                        "dimension": 512,
                        "method": {
                            "name": "hnsw",
                            "engine": "faiss",
                            "space_type": "l2",
                            "parameters": {
                                "ef_construction": 256,
                                "m": 48,
                            },
                        },
                    },
                    "video": {"type": "text"},
                    "image": {"type": "integer"},
                }
            },
        }

        # Tạo index
        response = client.indices.create(index=index, body=index_body)
        print(f"Index created: {response}")


def format_video_name(video_name):
    return video_name.split("/")[-1].split(".")[0]



def lambda_handler(event, context):
    print(event)

    bucket = event["Records"][0]["s3"]["bucket"]["name"]
    key = event["Records"][0]["s3"]["object"]["key"]

    # bucket = 'bucket-video-tftftftfttftf'
    # key = 'embeddings/L01_V001.npy'
    print(f"Bucket: {bucket}")
    print(f"Key: {key}")
    video_name = format_video_name(key)
    print("video name: ", video_name)

    # Create index if not exists
    if not client.indices.exists(index=OPENSEARCH_INDEX):
        create_index(OPENSEARCH_INDEX)
        print("Create index: " ,OPENSEARCH_INDEX)

    embeddings = s3_client.get_object(Bucket=bucket, Key=key)["Body"].read()
    embeddings = numpy.load(io.BytesIO(embeddings)).tolist()
    print("Embeddings: ", embeddings[0])

    # Create mapping of embeddings to video names
    docs = []
    for i, embedding in enumerate(embeddings):
        doc = {
            "_op_type": "index",
            "_index": OPENSEARCH_INDEX,
            "_id": f"{video_name}-{i+1}",
            "_source": {
                "image_embedding": embedding,
                "image": i+1,
                "video": video_name,
            },
        }
        docs.append(doc)
    print("Creating docs: OK")

    response = helpers.bulk(client, docs)

    print("Response: ", response)

    return {
        "statusCode": 200,
        "body": json.dumps("Indexing complete! , Key: " + video_name),
    }

