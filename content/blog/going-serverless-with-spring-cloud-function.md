+++
date = "2017-08-09T11:36:14+02:00"
title = "Going Serverless with Spring Cloud Function"
draft = false
+++

Serverless architectures are on the raise. Why? Well, if you deal with applications that have dynamic loads, a micro-service oriented architecture and you want to reduce to (almost) 0 operational costs, going serverless sounds pretty interesting. But what does it means _serverless_? It just means that instead of installing and deploying your application on a VM or a Docker container, you send the packaged application to a serverless provider, and hop - you have your application up and running somewhere, somehow. The magic behind instance provisioning, high-availability and deployment are provided for you.

Major Cloud providers AWS and Azure are in the game with their [AWS Lambda](https://aws.amazon.com/lambda/details/) and [Azure functions](https://azure.microsoft.com/en-us/services/functions/) respectively. But you can go self-hosted serverless too (sounds funny, right?): [Apache foundation OpenWhisk](http://openwhisk.apache.org/) and [Kubeless](https://github.com/kubeless/kubeless) and [fission](http://fission.io/) for Kubernetes are examples. 

And here is the search trend on Google about the topic, as you can see on a steady growth: 
![Google Trend for Serverless](/img/consul-ha/google_trend.png)

In this article I'll get right into a practical example using [Spring Cloud Function](https://github.com/spring-cloud/spring-cloud-function), a new (and unreleased!) module of the Java Spring Framework that enables developers to code "the Spring way" and do easy deployment in the cloud.

Spring Cloud Function
---------

Spring Cloud Function is a set of packaged functionalities that heavily rely on [Reactive Streams](http://www.reactive-streams.org/) and Java 8 Lambdas. To work with the module, you should first understand Reactive. But if you are in a rush, start by just taking a look at a definition of `[Flux](https://projectreactor.io/docs/core/release/api/reactor/core/publisher/Flux.html)`.

Go ahead and just clone the repository, and do a `mvn clean install` - the packaged JARs and POMs are not yet available on Central. 
Now prepare a new Java application, and add to the POM file a dependency to `spring-cloud-function-web`. You can use `spring-boot-starter-parent` as parent artifact. You will need only 1 Java class to get started:

    @SpringBootApplication
    public class Application {

      @Bean
      public Function<Flux<String>, Flux<String>> uppercase() {
        return flux -> flux.map(value -> value.toUpperCase());
      }

      public static void main(String[] args) {
        SpringApplication.run(Application.class, args);
      }
    }

Now run the application `mvn spring-boot:run`, and interact with your function 

    $ curl -H "Content-Type: text/plain" localhost:8080/uppercase -d 'Hello World'
    HELLO WORLD

The HTTP call maps to the bean `uppercase`, and executes the `Function`. The mapping between the servlet and the function is done in the class [`FunctionHandlerMapping`](https://github.com/spring-cloud/spring-cloud-function/blob/master/spring-cloud-function-web/src/main/java/org/springframework/cloud/function/web/flux/FunctionHandlerMapping.java) - reading the code of the class also shows that there are different mappings for GET and POST requests: a POST request will look for a matching `Function` or `Consumer` bean (and passes the body of the request to the bean), while a GET request will look for a `Supplier` or a `Function` (and in this case it will pass the remaining part of the URL path).

Of course, you can pass JSON, and the framework will use the default `ObjectMapper` to translate it (you can [configure Jackson the Spring Boot way](https://docs.spring.io/spring-boot/docs/current-SNAPSHOT/reference/htmlsingle/#howto-customize-the-jackson-objectmapper)). If you register your bean as taking as input a typed Spring `Message`, you can also access headers of the request ([see here](https://github.com/spring-cloud/spring-cloud-function/blob/master/spring-cloud-function-web/src/main/java/org/springframework/cloud/function/web/flux/request/FluxHandlerMethodArgumentResolver.java#L107)).

Where is the advantage in using this framework, instead of using class Spring Web? The first one is that the application code is completly isolated from _how_ your bean is called. The second one is that this structure even allows you to declare runtime microservices - and execute them on the fly (check the [scripts folder](https://github.com/spring-cloud/spring-cloud-function/tree/master/scripts) for details.

The isolation of the code from the calling infrastructure is key for serverless integrations. In fact, when you deploy on AWS or Azure, you can have multiple ways of executing your function - and Spring Function provides _adapters_ for those (currently, Openwhisk and AWS).

Running your Function on AWS Lambda
---------

We will use the [AWS lambda adapter](https://github.com/spring-cloud/spring-cloud-function/tree/master/spring-cloud-function-adapters/spring-cloud-function-adapter-aws) to deploy the same code on AWS Lambda. In your POM.xml just add the dependency `spring-cloud-function-adapter-aws`. You can still run the code locally as shown above, nothing changes. You will instead find in the `target` folder a new JAR - suffixed with `-aws`, which is the Spring Boot application wrapped in a Lambda-valid structure (which is, just a shaded jar :)). Now login to the AWS console and set-up a new Lambda function. Take a look at [Lambda pricing](https://aws.amazon.com/lambda/pricing/) - as of today you get free _1M free requests per month and 400,000 GB-seconds of compute time per month._, which basically means free testing.

To set-up your Lambda function, skip the Blueprint selection:
![AWS Lambda set-up](/img/serverless/aws_lambda_step_1.png)

If you want your Lambda function to be accessible from other applications, you need to define a trigger. Let's say that we set-up an SNS topic as a trigger, so that every message that gets into this SNS topic, will trigger a call to our function:
![AWS Lambda triggers](/img/serverless/aws_lambda_step_2.png)

Finally, you can upload your JAR file (the one suffixed with `-aws`). Remeber to set the type of function to be Java.
![AWS Lambda basic information](/img/serverless/aws_lambda_step_3.png)


