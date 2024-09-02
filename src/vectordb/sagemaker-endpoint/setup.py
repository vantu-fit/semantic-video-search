from sentence_transformers import SentenceTransformer
import tarfile
from sagemaker.pytorch import PyTorchModel
import time
import os

role_arn = os.environ.get("SAGEMAKER_ENDPOINT_ROLE_ARN")

# Wait for about 5 minutes
model = SentenceTransformer('clip-ViT-B-32')
model.save('model')


model_path = 'model/'
code_path = 'code/'

# Wait for about 5 minutes
zipped_model_path = os.path.join(model_path, "model.tar.gz")
with tarfile.open(zipped_model_path, "w:gz") as tar:
    tar.add(model_path)
    tar.add(code_path)

# Wait for about 20 minutes
endpoint_name = "clip-model-" + time.strftime("%Y-%m-%d-%H-%M-%S", time.gmtime())
model = PyTorchModel(
    entry_point="inference_code.py",
    model_data=zipped_model_path,
    role=role_arn,
    framework_version="1.5",
    py_version="py3",
)

predictor = model.deploy(
    initial_instance_count=1, instance_type="ml.m5.xlarge", endpoint_name=endpoint_name
)

# Wait total of 30 minutes