# Use the desired python image from AWS ECR public gallery
FROM public.ecr.aws/lambda/python:3.8

# Set the working directory in the container
WORKDIR /app

# Copy the requirements.txt file
COPY requirements.txt .

# Install the dependencies
RUN pip3 install --no-cache-dir -r requirements.txt --target "${LAMBDA_TASK_ROOT}"

# Copy the rest of the application code
COPY . ${LAMBDA_TASK_ROOT}

# Command to run the application
CMD ["app.lambda_handler"]