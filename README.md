![](images/terraws.png)
# Terraform-AWS-1
Terraform is an open-source tool created by **HashiCorp**. It is used for building, changing, and versioning infrastructure safely and efficiently. Terraform can manage existing and popular service providers as well as custom in-house solutions.

### For starting
![](images/terrastart1.png)
<br/>
![](images/terrastart2.png)

Here I have created a infrastructure in **HCL (Hashicorp Configuration Language)** which consists of 

### EC2 instance with configured Apache Server
  * Key Pair
  ![](images/key.png)
<br/>
  * Security Group
  ![](images/sg.png)
<br/>
  * EBS Volume
  ![](images/volume.png)
<br/>
  * Instance
  ![](images/instance.png)
<br/>
  
### S3 bucket with Public Access, consisting of all the data of GitHub repository
   * S3 bucket
   ![](images/bucket1.png)
   <br/>
   ![](images/bucket2.png)
   <br/>
   
   * Bucket Policy
   
### CloudFront Distribution for S3 bucket
![](images/distri.png)
<br/>

### CodePipeline for fully managed continous delievery that automatically copy the updates or pushes of GitHub repository into S3 bucket respectively
![](images/pipeline1.png)
<br/>
![](images/pipeline2.png)
<br/>
![](images/pipeline3.png)
<br/>
![](images/pipeline4.png)
<br/>
![](images/pipeline5.png)
<br/>
![](images/pipeline6.png)
<br/>
![](images/pipeline7.png)
<br/>

### At last here is the file for reference<br/>
[`Infrastructure.tf`](https://github.com/Sparsh-Agrawal/Terraform-AWS-1/blob/master/infra.tf)
