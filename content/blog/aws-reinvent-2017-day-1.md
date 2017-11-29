+++
title = "AWS re:Invent 2017 Day 1"
date = 2017-11-27T09:00:00+01:00
description = "First day at AWS:ReInvent 2017 in Las Vegas! Here are some rough notes from the conferences I’ve attended today"
tags = ["aws", "reinvent"]
draft = false

+++

First day at AWS:ReInvent 2017 in Las Vegas! Here are some rough notes from the conferences I've attended today (if you don't know, there are 10ths of conferences going on at the same time!). I will try to wrap-up a consolidated article on the most interesting and key takeaways at the end of the conference!

*[Link to Monday product announcements](https://aws.amazon.com/new/reinvent/):*

## Optimizing Costs as You scale on AWS

Reasons to move to the cloud: business agility, speed, costs

Pay for what you use vs pay for what you need => costs practices

GE example: 52% TCO reduction

#### Cost optimization foundations

- **right sizing instances** => prediction is hard, be ready to change. Test before reserving and measure with Cloudwatch (can optimize RAM on second step, as it requires instrumentation)

![aws reinvent day1 slide](/img/aws-reinvent-2017/day1/IMG_2953.jpg)

![aws reinvent day1 slide](/img/aws-reinvent-2017/day1/IMG_2954.jpg)

- **Elasticity** => turn off unused instances m automation with cloudwatch + lambda
- **Pricing model** (on demand, RI,spot) => RI 3y, payback 12 to 18 months. Changing architectures should leverage convertible RI . Up to 85% costs savings by combining the models of elasticity and RI . Lambda helps out by paying by load

![aws reinvent day1 slide](/img/aws-reinvent-2017/day1/IMG_2955.jpg)

- **Right storage solutions**: EBS vs EFS vs Instance store
- **Governance , measure, improve**. Governance: add rules to limit what resources can use (AWS service catalog) + IAM. Cost explorer + tagging (see pict for auto tag). AWS trust advisor + marketplace tools. Define success with KPIs (instances turned off daily, utilization...), define business value KPI (cost per user, per business process...). Generate a Cloud Center of Excellence (CCoE) to help define the process

![aws reinvent day1 slide](/img/aws-reinvent-2017/day1/IMG_2956.jpg)

![aws reinvent day1 slide](/img/aws-reinvent-2017/day1/IMG_2958.jpg)

![aws reinvent day1 slide](/img/aws-reinvent-2017/day1/IMG_2959.jpg)

**Expedia journey **

*Presentation by Expedia Financial officer* - cost optimization is finance related . Costs were a driver to move fast to cloud for Expedia:

![aws reinvent day1 slide](/img/aws-reinvent-2017/day1/IMG_2962.jpg)

![aws reinvent day1 slide](/img/aws-reinvent-2017/day1/IMG_2963.jpg)

Finance as a part of technology, not an annex. Cost to be part of the process as transparency. Use custom tools to have deeper understanding of where you are spending in the cloud

![aws reinvent day1 slide](/img/aws-reinvent-2017/day1/IMG_2965.jpg)

![aws reinvent day1 slide](/img/aws-reinvent-2017/day1/IMG_2966.jpg)

 Tag everything. Destroy untagged instances! Cost awareness part of devops culture - tribes that discuss cost optimization strategies.

![aws reinvent day1 slide](/img/aws-reinvent-2017/day1/IMG_2967.jpg)

Always on instances are at least acquired 1y RI partial upfront. 80% RIs now with RI utilization rate at 97%.

**Objective to be 100% cloud!**



## Building a Solid Business case for Cloud

Disruption is around us. Cloud is an enabler of innovation. The presentation is about tools and frameworks for building business case for cloud, with examples.

3 types of business cases from high level to detailed business case.

There is right time to build the business case - usually it happens at one of those phases:

- project
- Foundation
- Migration (r hosting, redesign...)
- Reinvention to move legacy to cloud native

Regardless of when it is developed, the business case is built around the **TCO**: server, storage, network + facility costs (space, power, cooling....), migration costs (development, tools, people, dual location).

![aws reinvent day1 slide](/img/aws-reinvent-2017/day1/IMG_2972.jpg)

Cannot compare costs as 1:1: needs to take into account re-architected environment. Possible technology optimizations are:

1. **Services** (EC2 vs highest value services)
2. **Fit**: instance type, storage class...
3. **Price**; purchasing options, licensing (bring your own licenses, marketplace...)
4. **Scale**: time/event based
5. **Iterate** and keep improving when new opportunities are available (new instances classes, paradigms...)

![aws reinvent day1 slide](/img/aws-reinvent-2017/day1/IMG_2973.jpg)

**decide where your value is: infrastructure or services that run on it?**

Add non technology components in the business cases: agility, technical capabilitires, devops, CD => **AWS Cloud Adoption Framework**

![aws reinvent day1 slide](/img/aws-reinvent-2017/day1/IMG_2974.jpg)

Private cloud business case usually wins because it does not factor in all the cost factors (real estate, HVAC, physical security...)

Create momentum for cloud adoption through people, Cloud Center Of Excellence.

**Cost of inaction:** include application modernization, hardware refresh, software licensing, integration of new IT HW/SW with legacy - and is required to be taken into account for TCO comparison.

#### Tangible benefits

Gartner : 70% of time is used on IT to keep light on. Cloud reverses the business by prioritizing innovation over running.

![aws reinvent day1 slide](/img/aws-reinvent-2017/day1/IMG_2975.jpg)

**Cost avoidance**: do not spend for what does not bring business value - but keep flexibility and speed, by matching supply with actual demand (for instance, peak absorption)

**Operational costs: **reduce tasks by automation, no hardware maintenance, reduce security compliance

#### Intangible benefits

![aws reinvent day1 slide](/img/aws-reinvent-2017/day1/IMG_2976.jpg)

**Business agility: **lower risks of CAPEX, faster application development, faster TTM

![aws reinvent day1 slide](/img/aws-reinvent-2017/day1/IMG_2977.jpg)

**Workforce productivity**: self service culture, increased automation, satisfied developers and higher team retention

**Resilience**: quantify resilience, and bug reduction due to smaller and more incremental changes

![aws reinvent day1 slide](/img/aws-reinvent-2017/day1/IMG_2978.jpg)



## Serverless for Security Officers: Paradigm walkthrough and comprehensive Security best practices

*Note: this was a chalk-talk: most of the discussion happened as a Q&A format!*

![aws reinvent day1 slide](/img/aws-reinvent-2017/day1/IMG_2979.jpg)

Frameworks of reference for security in access in serverless environments: ISO 27001 A.9.* and NIST 800-53 AC-*, AU-*

Frameworks of reference for security in networking in serverless environments:

![aws reinvent day1 slide](/img/aws-reinvent-2017/day1/IMG_2980.jpg)

Example uses Cognito to log users through federated providers.

Lambda execution role vs user role: the lambda role envelops what it could do the function. The user role is what this user is authorized to do - and it cannot do more than what the lambda role was allowed to do.

Serverless enables to decouple security from code: using API gateway and Cognito, and enabling VPC logs gives full policy enforcing and visibility on the IT - regardless of the application running below.

*Recommendation from Lambda PM:* Don’t reuse roles across different lambda functions

Restrict lambda function by subnets the same way you do EC2.



## Building Enterprise Data Warehouse, Analytics, and Ad Hoc Solutions on the AWS Big Data Platform

*Note: this was a chalk-talk: most of the discussion happened as a Q&A format!*

![aws reinvent day1 slide](/img/aws-reinvent-2017/day1/IMG_2981.jpg)

![aws reinvent day1 slide](/img/aws-reinvent-2017/day1/IMG_2982.jpg)

Glue to parameter etl from s3. Pg_bouncer to federate access to redshift.

Data lake and data warehousing are complementary - not replacing each other. Separation of storage capacity from operations.

DB2 migration to redshift - DMS will support DB2 or use Apache Sqoop EMR job.

Glue has a Apache Hive compatible metastore: possible to do querying using Athena and/or Hive!



## Real-World AI and Deep learning for the Enterprise

AI cycle:

![aws reinvent day1 slide](/img/aws-reinvent-2017/day1/IMG_2985.jpg)

AI to solve major problems- perception, language...

![aws reinvent day1 slide](/img/aws-reinvent-2017/day1/IMG_2987.jpg)

- Amazon fulfillment centers example (robots)
- FDA approved imaging analysis
- many business cases already using AI:

![aws reinvent day1 slide](/img/aws-reinvent-2017/day1/IMG_2988.jpg)

Organizational process : identify a business problem to solve as the starting point of the ML process. Data ingestion and normalization is 70% of complexity of an AI project:

![aws reinvent day1 slide](/img/aws-reinvent-2017/day1/IMG_2992.jpg)

AWS can cover for all the phases of ML process.

![aws reinvent day1 slide](/img/aws-reinvent-2017/day1/IMG_2993.jpg)

### CapitalOne business case

Machine learning projects have a continuous improvement lifecycle, contrast with classic sw development cycle. Example: fraud schemes, security.

Layering of custom developed solutions on top of AWS to cover for additional feature including compliance for financial services (historical data reconstruction, versioning, monitoring...)

![aws reinvent day1 slide](/img/aws-reinvent-2017/day1/IMG_2995.jpg)

ML is multidisciplinary and requires integrated teams: critical requirement for successful projects:

![aws reinvent day1 slide](/img/aws-reinvent-2017/day1/IMG_2996.jpg)

How: talents, create an environment for them to work, centralize new technologies. => **center of excellence in machine learning to achieve the goal**