+++
date = "2017-08-09T11:36:14+02:00"
title = "Going Serverless with Spring Cloud Function"
draft = true
+++

Serverless architectures are on the raise. Why? Well, if you deal with applications that have dynamic loads, a micro-service oriented architecture and you want to reduce to (almost) 0 operational costs, going serverless sounds pretty interesting. But what does it means _serverless_? It just means that instead of installing and deploying your application on a VM or a Docker container, you send the packaged application to a serverless provider, and hop - you have your application up and running somewhere, somehow. The magic behind computing provisioning, high-availability, deployment and all the related hassle is provided for you.

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


