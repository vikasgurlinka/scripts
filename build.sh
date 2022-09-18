#!/bin/bash
# Bash Menu Script Example

PS3='Please enter your choice: '
options=("Install Dependencies" "Build Jar" "Build Image" "Run Image" "Push Image to ECR" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "Install Dependencies")
            echo "-------------------Installing Dependencies----------------------------"
            sudo yum update -y
            echo "
			
			------------------------Installing Java-------------------------------
			
			"
            sudo yum install java
            echo "
			
			-----------------------Installing maven-------------------------------
			
			"
            wget https://mirrors.estointernet.in/apache/maven/maven-3/3.6.3/binaries/apache-maven-3.6.3-bin.tar.gz
            tar -xvf apache-maven-3.6.3-bin.tar.gz
            sudo mv apache-maven-3.6.3 /opt/
            echo "M2_HOME='/opt/apache-maven-3.6.3'" >> ~/.bash_profile
            echo "PATH='$M2_HOME/bin:$PATH'" >> ~/.bash_profile
            echo "export PATH" >> ~/.bash_profile
	    sudo ln -s /opt/apache-maven-3.6.3/bin/mvn /usr/bin/mvn
	    rm -rf apache-maven-3.6* 
            echo "
			
			-----------------------Installing Docker-------------------------------
			
			"
	    sudo yum install docker -y
            sudo usermod -aG docker ec2-user
            sudo systemctl start docker
	    systemctl status docker
	    echo "------------------- Done depenendency Installation ---------------------------"
            ;;
        "Build Jar")
	    echo "-----------------------Creating Jar----------------------"
	    mvn clean
	    ./mvnw -DskipTests package
            #echo "you chose choice $REPLY which is $opt"
            ;;
	"Build Image")
            build_jar=`ls target/*.jar`	  
            echo "------------------- Creating Docker Image for $build_jar -------------------------"
            sudo mvn spring-boot:build-image
	    echo "
		
		##########------------------------------------------############
		
		"
        echo -e "REPOSITORY\t\tTAG\tIMAGE ID\tCREATED \tSIZE"
	    sudo docker images | grep -i search-grs
		echo '\n'
	    ;;
        "Run Image")
	    echo "you choose choice $REPLY which is $opt"
            echo "########----No commads Added-----############"
            ;;
        "Push Image to ECR")
            echo "########----------- Provide the below details to $OPT--------------###########"
            echo "
	   1. repository path:90xxxxxxxxxx.dkr.ecr.<your region>.amazonaws.com
	   2. repository name: <your repository name>
           3. access key id: XXXXXXXXXXXXX
	   4. secret access key: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
	   5. region: <your region>
	   6. output format: json
	    "
	    read -p 'repository path: ' repo_path
	    read -p 'repository name: ' repo_name
	    read -p 'region: ' region
            echo "$repo_path $repo_name"
	    aws configure
            sudo docker login -u AWS -p $(aws ecr get-login-password --region $region) $repo_path
	    sudo docker images
	    echo "
		########----------
	    provide name of the image to be pushed as Repository:Tag 
		----------########
		"
	    read -p 'image name: ' imagename
	    sudo docker tag $imagename $repo_path/$repo_name:search_grs
	    sudo docker push $repo_path/$repo_name:search_grs
            ;;
        "Quit")
            break
            ;;
        *) echo "invalid option $REPLY";;
    esac
done
