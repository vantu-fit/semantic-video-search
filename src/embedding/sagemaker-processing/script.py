import os
import sys
import subprocess

subprocess.check_call(
    [
        sys.executable,
        "-m",
        "pip",
        "install",
        "-r",
        "/opt/ml/processing/code/requirements.txt",
    ]
)
import torch
from sentence_transformers import SentenceTransformer
from PIL import Image
import numpy


def processor(input_dir, output_dir , folder):
    print("Loading model.....")
    model = SentenceTransformer("clip-ViT-B-32")
    print("Model loaded")
    device = "cuda" if torch.cuda.is_available() else "cpu"
    model = model.to(device)
    print(f"Using device: {device}")

    
    image_paths = os.listdir(os.path.join(input_dir))
    images = []
    for image_path in image_paths:
        image = Image.open(os.path.join(input_dir, image_path))
        images.append(image)

    embeddings = model.encode(images)

    numpy.save(os.path.join(output_dir, f"{folder}.npy"), embeddings)
    print(f"Embeddings for {folder} saved")


if __name__ == "__main__":
    input_dir = "/opt/ml/processing/input"
    output_dir = "/opt/ml/processing/output"

    # Local testing
    # input_dir = "./dataset/keyframes/L01_V001"
    # output_dir = "./dataset/output"
    s3_out_dir = os.environ.get('S3_OUTDIR')
    if s3_out_dir is None:
        raise ValueError("S3_OUTDIR environment variable is not set")

    print("Starting processing.....")

    processor(input_dir, output_dir , s3_out_dir)

    print("Processing complete")