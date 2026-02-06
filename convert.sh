#!/bin/bash

# Convert ONNX model to RKNN format
# Usage: bash convert.sh <model_name> <convert_args>
# Usage: bash convert.sh --download <model_name>
# Usage: bash convert.sh --get-model-dir <model_name>

# Function to get model directory from model name
get_model_dir() {
  local MODEL_NAME="$1"
  if [ -z "$MODEL_NAME" ]; then
    MODEL_NAME="yolov7"
  fi
  echo "examples/$MODEL_NAME"
}

# Function to download model
download_model() {
  local MODEL_NAME="$1"
  local MODEL_DIR=$(get_model_dir "$MODEL_NAME")
  
  echo "=== Downloading model ==="
  echo "Model name: $MODEL_NAME"
  echo "Model directory: $MODEL_DIR"
  echo ""
  
  # Check if model directory exists
  if [ ! -d "$MODEL_DIR" ]; then
    echo "Error: Model directory does not exist: $MODEL_DIR"
    exit 1
  fi
  
  # Change to model directory and run download script
  cd "$MODEL_DIR/model"
  echo "Current directory: $(pwd)"
  ls -la
  bash download_model.sh
  
  # Return to original directory
  cd - > /dev/null
}

# Function to convert model
convert_model() {
  local MODEL_NAME="$1"
  local CONVERT_ARGS="$2"
  local MODEL_DIR=$(get_model_dir "$MODEL_NAME")
  
  # Set default values
  if [ -z "$CONVERT_ARGS" ]; then
    CONVERT_ARGS="rk3588 i8"
  fi
  
  echo "=== ONNX to RKNN Conversion Script ==="
  echo "Model name: $MODEL_NAME"
  echo "Model directory: $MODEL_DIR"
  echo "Conversion arguments: $CONVERT_ARGS"
  echo ""

  # Check model directory structure
  echo "=== Checking directory structure ==="
  if [ -d "$MODEL_DIR" ]; then
    echo "Model directory exists: $MODEL_DIR"
    ls -la "$MODEL_DIR/"
  else
    echo "Error: Model directory does not exist: $MODEL_DIR"
    exit 1
  fi

  if [ -d "$MODEL_DIR/model" ]; then
    echo "Model subdirectory exists: $MODEL_DIR/model"
    ls -la "$MODEL_DIR/model/"
  else
    echo "Error: Model subdirectory does not exist: $MODEL_DIR/model"
    exit 1
  fi

  if [ -d "$MODEL_DIR/python" ]; then
    echo "Python subdirectory exists: $MODEL_DIR/python"
    ls -la "$MODEL_DIR/python/"
  else
    echo "Error: Python subdirectory does not exist: $MODEL_DIR/python"
    exit 1
  fi

  echo ""

  # Get ONNX model path relative to python directory
  echo "=== Finding ONNX model ==="
  ONNX_FILE=$(ls "$MODEL_DIR/model/" | grep \.onnx$ | head -1)
  if [ -z "$ONNX_FILE" ]; then
    echo "Error: No ONNX model found in $MODEL_DIR/model/"
    exit 1
  fi

  ONNX_MODEL="../model/$ONNX_FILE"
  echo "Found ONNX model: $ONNX_FILE"
  echo "Using relative path: $ONNX_MODEL"
  echo ""

  # Run convert.py with provided arguments
  echo "=== Running conversion ==="
  cd "$MODEL_DIR/python"
  echo "Current directory: $(pwd)"
  echo "Running command: python3 convert.py $ONNX_MODEL $CONVERT_ARGS"

  # Execute the conversion
  python3 convert.py "$ONNX_MODEL" $CONVERT_ARGS

  # Check exit code
  if [ $? -eq 0 ]; then
    echo ""
    echo "=== Conversion completed successfully! ==="
    exit 0
  else
    echo ""
    echo "=== Conversion failed! ==="
    exit 1
  fi
}

# Main script logic
if [ "$1" == "--download" ]; then
  # Download model
  download_model "$2"
elif [ "$1" == "--get-model-dir" ]; then
  # Get model directory
  get_model_dir "$2"
else
  # Convert model
  convert_model "$1" "$2"
fi
