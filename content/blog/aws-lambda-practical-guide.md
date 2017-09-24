+++
date = "2017-09-24T16:29:41+02:00"
title = "AWS Lambda: a practical guide - networking"
draft = false
+++

In the [previous article](https://blog.mywebofthings.com/blog/going-serverless-with-spring-cloud-function/) we deployed a Spring Cloud Function with AWS Lambda. This series of articles will get more into the detail of AWS Lambda: you will see that there are a lot of caveats and attention points that you should consider. The first article will go into the details of the **networking model**. 

Networking is an interesting consideration in serverless architectures: since Lambda provides triggers that abstract the actual networking model of your function, why do you need to care? There are some scenarios in which you will still need to design networking: outgoing connections to the internet, integration with on-premises VPN-based resources and connection to VPC resources (such as RDS databases, or ElastiCache instances).

To VPC or not to VPC?
--------------
If you followed the [Spring Cloud Function example](https://blog.mywebofthings.com/blog/going-serverless-with-spring-cloud-function/), you have already noticed that deploying outside of an existing VPC is straightforward. Moreover, a Lambda function deplyoed that way gets **outgoing Internet connectivity** without additional configuration. If you log-in to the EC2 console of the region where you deployed the Function, you will also notice that no _Network Interface_ is created. That's because AWS took care of deploying the code, _somewhere_, _somehow_ in that region - and that's all you need. 

And since you are outside of a VPC, you cannot configure _Security Groups_, not _Availability Zones_. This means that your function has no direct outgoing access to the VPC resources - unless you route through the public web.

To test this configuration, I've created a [test Spring Cloud Function application](https://github.com/sybeck2k/serverless-spring-cloud-demo), packaged with Terraform scripts to deploy with and without a VPC. The code simulates a producer of logs, that sends it to an SNS topic or to a dummy logger, and a consumer of logs, that gets the log, and computes the length of the `message` filed of the log. You can run it locally without SNS, and then test it out by calling the functions individually, or pipelining them as below:

    $ curl -H "Content-Type: application/json" localhost:8080/produceLog
    {"tags":null,"message":"odrkrc tnzgo ifd ujrx erbwoypv hjnab cre sjyuozgy lgja iaoddxzsbg ","eventTime":"2017-08-20T12:48:24"}
    $ curl -s -H "Content-Type: application/json" localhost:8080/produceLog | curl -s -H "Content-Type: application/json" -d @- localhost:8080/countLogMessageLength 
    76

When deploying to AWS, we create 2 separate Lambda functions - the `test_publisher` function that emits the log to SNS, and that is triggered every minute by a CloudWatch scheduled event, and the `test_consumer` function, that is triggered by SNS events. This schema shows the overall picture:
![Lambda sample application without VPC](/img/serverless/aws_lambda_sample_no_vpc.png)

Go ahead and deploy with Terraform by running `terraform apply` in the `terraform/no-vpc` folder (you can change some settings through the `variables.tf` file). Once completed, every minute a new log line will be generated. You can check the CloudWatch logs of the consumer function, to see the end results. You can use the AWS Console, or

    $ aws logs filter-log-events --region us-west-1 --log-group-name  "/aws/lambda/test-log-consumer" | jq '.events | .[] | .message'    
    "START RequestId: 905bdf4d-8599-11e7-bf3d-8d1ccbda29d0 Version: $LATEST"
    "2017-08-20 11:20:25.715 DEBUG 1 --- [           main] com.mywebofthings.test.Application       : Received a log with message length of 75"
    "END RequestId: 905bdf4d-8599-11e7-bf3d-8d1ccbda29d0"
    "REPORT RequestId: 905bdf4d-8599-11e7-bf3d-8d1ccbda29d0	Duration: 0.77 ms	Billed Duration: 100 ms 	Memory Size: 512 MB	Max Memory Used: 100 MB"
    "START RequestId: b407cd68-8599-11e7-970e-8f39f36b80cc Version: $LATEST"
    "2017-08-20 11:21:25.583 DEBUG 1 --- [           main] com.mywebofthings.test.Application       : Received a log with message length of 82"
    "END RequestId: b407cd68-8599-11e7-970e-8f39f36b80cc"
    "REPORT RequestId: b407cd68-8599-11e7-970e-8f39f36b80cc	Duration: 0.92 ms	Billed Duration: 100 ms 	Memory Size: 512 MB	Max Memory Used: 100 MB"
    "START RequestId: d8195a75-8599-11e7-9259-9d5afc12e5c2 Version: $LATEST"
    "2017-08-20 11:22:26.079 DEBUG 1 --- [           main] com.mywebofthings.test.Application       : Received a log with message length of 77"
    "END RequestId: d8195a75-8599-11e7-9259-9d5afc12e5c2"
    "REPORT RequestId: d8195a75-8599-11e7-9259-9d5afc12e5c2	Duration: 0.94 ms	Billed Duration: 100 ms 	Memory Size: 512 MB	Max Memory Used: 100 MB"
    "START RequestId: fbe21e99-8599-11e7-a8df-b7d348b35027 Version: $LATEST"

It should be noted that the `test-log-publiser` is using Internet access to call the SNS API entrypoint. Once you are done testing, you can destroy the platform with `terraform destroy`

AWS Lambda within a VPC
--------------
We will now deploy the same application in a VPC. If you read the [AWS documentation](http://docs.aws.amazon.com/lambda/latest/dg/vpc.html) you will see that a Lambda function will be executed on a _private_ network resource on the VPC - and as such, it does not have Internet access. That's because the default Internet Gateway connected to a public route on a VPC requires the using instances to have a public IP. You will have thus to use a [NAT gateway](http://docs.aws.amazon.com/AmazonVPC/latest/UserGuide/vpc-nat-gateway.html), managed by you with a dedicated EC2 instance, or by AWS.

And, since the Lambda function now belongs to a VPC managed by you, you are required to provide also _Subnets_ (and thus, it's up to you to provide multi-AZ to AWS to be able to re-launch instances in different AZs in case of a zone failure) and _Security Groups_.

To understand better the architecture, I recommend reading through the [Terraform script](https://github.com/sybeck2k/serverless-spring-cloud-demo/blob/master/terraform/with-vpc/main.tf) that we will use to deploy the application on a VPC: you will see that we have to declare the NAT Gateway for the private network, the Internet Gateway for the public network (where the NAT GW belongs), the private subnets on 2 different AZs for the Lambda functions, and the routing tables to connect everthing. Moreover, we need to extend the authorizations to the Lambda service: when deploying the function, Lambda _might_ (yes, not always!) generate new network interfaces in EC2.

Let's deploy everything by running `terraform apply` in the `terraform/with-vpc` folder. It will take a bit longer than above, as we are actually generating a more complex infrastructure. You can check the CloudWatch logs exactly as above to verify that everything is running correctly.

If you check the AWS EC2 Console, you will find in fact the Network interfaces that are associated to the actual instances (which are not visibile - as fully managed by AWS) where the Lambda functions are executing (only 1 in the screenshot below):
![Lambda function network interface](/img/serverless/aws_lambda_network_interface.png)

When the Lambda function scales up, for instance when requests triggers are increasing, you might notice that more interfaces are added. Internally, Lambdas use the EC2 API, and have thus the same limits in terms of execution scale. It is recommended to [pay attention to those limits and learn how to adapt](http://docs.aws.amazon.com/lambda/latest/dg/concurrent-executions.html).

And remember to *provide enough available IP addresses in the subnets used by Lambdas*.

