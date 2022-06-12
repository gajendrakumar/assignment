
<img width="767" alt="Screenshot 2022-06-11 at 7 00 52 PM" src="https://user-images.githubusercontent.com/5584558/173190060-524e7c20-55c1-402c-a6e3-f967858b3e6b.png">


1 . Architecture:
![image](https://user-images.githubusercontent.com/5584558/173242165-5fb4eb7c-74bb-48de-b3b7-847f54ee1d8e.png)



2. Overview of task:
 
   The task achievement involves 2 steps and jenkins jobs screen shots attached for the same 
   step 1 
     Jenkins job1 : This job build the docker file and tag the image with ecr formate uploadable and upload image to the ecr
     Jenkins Job2 : This job init and apply the (IAC) terrform code to deploy basic infra and spin up container in the ECS cluster
     ![image](https://user-images.githubusercontent.com/5584558/173242673-58fb0d06-02cc-4deb-8a7c-a12fe3cf5964.png)


3. Prerequisites:

    AWS CLI to to installed 
    Install terraform 
    configure AWS access key and secret key in the system path (.aws/credentials file)

4. How to apply execute the code and achieve task:

    Its very simple . Just trigger the jenkins job 1
    

