import * as cdk from 'aws-cdk-lib';
import * as lambda from 'aws-cdk-lib/aws-lambda';
import * as apigateway from 'aws-cdk-lib/aws-apigateway';
import { Construct } from 'constructs';
// import * as sqs from 'aws-cdk-lib/aws-sqs';

export class CdkStack extends cdk.Stack {
  constructor(scope: Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);

    const pythonLambda = new cdk.aws_lambda.Function(this, "cdkHelloWorldLambda", {
      functionName: "cdk-hello-world",
      runtime: lambda.Runtime.PYTHON_3_9,
      handler: "hello_world.lambda_handler",
      code: lambda.Code.fromAsset(__dirname + "../../../lambda_functions"),
      environment: {
        deployment_mechanism: "AWS CDK"
      }
    })

    const api = new apigateway.RestApi(this, "widgets-api", {
      restApiName: "cdk-workshop-api-gateway",
      description: "Deployed via CDK"
    });

    const getWidgetsIntegration = new apigateway.LambdaIntegration(pythonLambda, {
      requestTemplates: { "application/json": '{ "statusCode": "200" }' }
    });

    const messageResource = api.root.addResource("message")

    messageResource.addMethod("GET", getWidgetsIntegration);
    messageResource.addCorsPreflight({
      allowOrigins: ["*"],
      allowHeaders: ["*"],
      allowMethods: ["*"],
      allowCredentials: true,
    });

  }
}
