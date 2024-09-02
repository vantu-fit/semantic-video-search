from sentence_transformers import SentenceTransformer
import json
import os


def model_fn(model_dir):

    model_path = os.path.join(model_dir, "model")   

    model = SentenceTransformer(model_path)

    return model

def input_fn(request_body, request_content_type):
    if request_content_type == "application/json":
        input_data = json.loads(request_body)
    else:
        return request_body

    return input_data["text"]
    


def predict_fn(input_data, model):
    embeddings = model.encode(input_data)
    return embeddings


def output_fn(prediction, content_type):
    if content_type == "application/json":
        return json.dumps({"embeddings": prediction.tolist()})
    else:
        return "content type not supported"