# Pet Grooming Appointment Demo

- Lex bot to make appointments for grooming pets.
- Lambda function to serve as the backend for the Lex bot, which will insert appointment details into an RDS database.
- Simple web application using the App Runner service to review and cancel appointments.

## Stages of the Demo

### Stage 1: Create the ECR Repository and Lambda Function
- Set up an Elastic Container Registry (ECR) to store your container images.
- Develop a Lambda function that processes appointments and integrates with the Lex bot.

### Stage 2: Create the RDS Database
- Deploy a relational database using Amazon RDS.
- Configure the database to store appointment information.

### Stage 3: Build the Docker Image, Create Parameter Store Entries, and Set Up the RDS Database
- Build a Docker image for your application.
- Use AWS Systems Manager Parameter Store to securely manage application secrets.
- Set up and initialize the RDS database.

### Stage 4: Create and Configure the Lex Bot
- Develop a Lex bot with intents and slots for scheduling pet grooming appointments.
- Integrate the bot with the Lambda function as a fulfillment backend.

### Stage 5: Deploy the Application Using App Runner
- Deploy the web application using AWS App Runner.
- The application will provide an interface to view and cancel appointments.

### Stage 6: Test the Bot and Review the Appointments
- Interact with the Lex bot to schedule a grooming appointment.
- Use the web application to review and cancel appointments.
