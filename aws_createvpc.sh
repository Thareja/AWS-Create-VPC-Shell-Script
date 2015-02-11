#!/bin/bash
# Filename    : aws_createvpc.sh
# Created by  : Dhiraj Thareja 
# Version     : Beta 1.0
# Company     : AwesomeActually.com
# Description : Creates VPC, subnets, & EC2 instances in AWS. Also add tags to items. 


case $1 in
        --vpc| --VPC)
                echo -n "Enter Region(us-east-1,eu-west-1,us-west-2,us-west-1,ap-southeast-1,ap-northeast-1,ap-southeast-2) >"
                read REGION
                echo -n "Choose options: LIST_VPC, CREATE_VPC >"
                read OPT
        if [ $OPT = "LIST_VPC" ]
        then
                 echo "Listing the available VPCs in region $REGION"
                 aws ec2 describe-vpcs --output text --region $REGION | awk '{ print $1,$5 }' | head -2
                 exit 0
        elif [ $OPT = "CREATE_VPC" ]
        then
                 echo -n "Enter CIDR for new VPC (Ex:10.0.0.0/16)>"
                 read VPC_CIDR
                 echo -n "Creating VPC with CIDR Block"
#echo -n "Enter Instance Tenancy ( Default/Dedicated) >"
#read INSTANCE_TENANCY
                aws ec2 create-vpc --cidr-block $VPC_CIDR --instance-tenancy default --region $REGION
                if [ $? -ne "0" ]
                then
                        echo "VPC creation failed"
                        exit 1
                fi
        else
                echo "Wrong input"
        fi

        echo -n "DO you want to create a subnet (yes/no) >"
        read ANS2
        if [ $ANS2 = "yes" ]
        then
                echo " Select a VPC to create subnets"
                sleep 2
                echo "List of VPCs available in region $REGION "
                aws ec2 describe-vpcs --output text --region $REGION | awk '{ print $1,$5 }'
                echo -n "Choose one VPC from above list >"
                read VPC_ID
                echo " Existing Subnets"
o -n "How many new subnets you want to create (ex: 1/2/3/5/10/20) >"
                read ANS1
                        for i in `seq $ANS1`
                        do
                                echo -n "$i-Enter Subnet range: Ex: 10.0.0.0/24, 10.0.1.0/24, 10.0.2.0/24, 10.1.1.0/24 >"
                                read CIDR_SUBNET
                                echo -n " Enter tag Name for the subnet >"
                                read TAG
                                echo -n "Enter the stack name for subnet >"
                                read STACK
                                echo "creating subnet"
                                aws ec2 create-subnet  --vpc-id $VPC_ID --cidr-block $CIDR_SUBNET --region $REGION
                                x=`aws ec2 describe-subnets --output text --region $REGION  | grep "$CIDR_SUBNET" | awk '{ print $7 }'`
                                aws ec2 create-tags --resources $x --tags Key=$TAG,Value=$STACK --region $REGION
                        done
        else
                echo "Thank You"
                exit 0
        fi
;;
################################################################################################
        --create-instance )
                echo -n "Enter Region(us-east-1,eu-west-1,us-west-2,us-west-1) >"
                read REGION
                echo "============================================================"
                if [ $REGION = "eu-west-1" ]
                then
                        echo "EU Region: Amazon Linux= ami-c7c0d6b3"
                        echo "EU Ragion: Redhat 6.4 = ami-75342c01"
                        echo -n "Select AMI from the list >"
                        read AMI
                        if [ "$AMI" != "ami-c7c0d6b3" ] && [ "$AMI" != "ami-75342c01" ]
                        then
                                echo "Invalid AMI"
                                exit 1
                        fi
                elif [ $REGION = "us-east-1" ]
                then
                        echo "US East(Virginia): Amazon Linux = ami-05355a6c"
                        echo "US East(Virginia): Redhat 6.4 = ami-a25415cb"
                        echo -n "Select AMI from the list >"
                        read AMI
                        if [ $AMI != "ami-05355a6c" ] && [ $AMI != "ami-a25415cb" ]
                        then
                                echo "Invalid AMI"
                                exit 1
                        fi
                elif [ $REGION = "us-west-1" ]
                then
                        echo "Us West-1(California) : Amazon Linux = ami-3ffed17a"
                        echo "Us West-1(California) : Redhat 6.4 = ami-6283a827"
                        echo -n "Select AMI from the list >"
                        read AMI
                        if [ $AMI != "ami-3ffed17a" ]  && [ $AMI != "ami-6283a827" ]
                        then
                                echo "Invalid AMI"
                                exit 1
                        fi
                elif [ $REGION = "us-west-2" ]
                then
                        echo "Us West-2(Oregon) : Amazon Linux = ami-0358ce33"
                        echo "Us West-2(Oregon) : Redhat 6.4 = ami-b8a63b88"
                        echo -n "Select AMI from the list >"
                        read AMI
                        if [ $AMI != "ami-0358ce33" ] && [ $AMI != "ami-b8a63b88" ]
                        then
                                echo "Invalid AMI"
                                exit 1
                        fi
                else
                        echo "Invalid Region"
                        exit 1
                fi
                #######################
                echo " AMI is selected: $AMI"
                echo "============================================================"
                echo "######Choose KeyPair#####"
                aws ec2 describe-key-pairs --output text --region $REGION | awk '{ print $1}' | head -2
                echo -n "Choose one >"
                read KEY
                echo "============================================================"
                echo "######Choose VPC######"
                echo "Listing the available VPCs in region $REGION"
                aws ec2 describe-vpcs --output text --region $REGION | awk '{ print $1,$4,$5 }' | head -2
                echo -n "Choose VPC >"
                read VPC
                echo "Available Subnets for the VPC $VPC"
                aws ec2 describe-subnets --output text --region $REGION | grep $VPC | awk '{ print $7,$2}'
                echo -n "Choose Subnet>"
                read SUBNET
                echo "============================================================"
                echo "#####Choose Security Group#####"
                echo -n "Create new security group? Type "yes" to create new or "no" to continue >"
                read ANS1
                if [ $ANS1 = "yes" ]
                then
                        echo -n "Enter security group name >"
                        read SG_NAME
                        aws ec2 create-security-group --group-name $SG_NAME --vpc-id $VPC --description $SG_NAME --region $REGION
                        if [ $? != 0 ]
                        then
                                echo "Creation of Security group failed"
                                exit 1
                        fi
                        sleep 3
                fi
                aws ec2 describe-security-groups --region $REGION --output=text | grep $VPC | awk '{ print $5,$1,$8 }'
                echo -n "choose Security Group ID>"
                read SG_ID
                echo " ==========================================================="
                echo "#####Select instance Type######"
                echo -n "Valid values: t1.micro | m1.small | m1.medium | m1.large | m1.xlarge | m3.xlarge | m3.2xlarge | c1.medium | c1.xlarge | m2.xlarge | m2.2xlarge | m2.4xlarge | cr1.8xlarge | hi1.4xlarge | hs1.8xlarge | cc2.8xlarge | cg1.4xlarge >"
                read INSTANCE_TYPE
                echo "============================================================"
                echo -n "Enter a name for the instance >"
                read INSTANCE_NAME
                echo -n "Enter Owner name for the stack >"
                read OWNER_NAME
                echo -n "Enter Customer Name >"
                read CUST_NAME
                echo "============================================================"
                echo "============================================================"
                echo "============================================================"
                echo "Please confirm the details"
                echo -e "Region: $REGION \nAMI:$AMI \nKeyPair:$KEY \nVPC=$VPC \nSubnet:$SUBNET \nSecurityGroupID:$SG_ID \nInstanceType:$INSTANCE_TYPE \nInstanceName:$INSTANCE_NAME \nOwner:$OWNER_NAME \nCustomerName:$CUST_NAME"
                echo "Please enter "yes" to confirm the details to continue>"
                read ANS2
                echo "============================================================"
                if [ $ANS2 = "yes" ]
                then
                        INSTANCE_ID=`aws ec2 run-instances --image-id $AMI --min-count 1 --max-count 1 --key-name $KEY --security-group-ids $SG_ID --instance-type $INSTANCE_TYPE --subnet-id $SUBNET --region $REGION | grep "InstanceId" | awk '{ print $2 }' | tr -d  '"' | tr -d ','`
                        echo "Please wait while we launch the instance for you..."
                        sleep 5
                        if [ $? != 0 ]
                        then
                           echo "Machine creation failed"
                        else
                           echo "Instance startup success"
                           aws ec2 create-tags --resources $INSTANCE_ID --tags Key=Name,Value=$INSTANCE_NAME --region $REGION
                           aws ec2 create-tags --resources $INSTANCE_ID --tags Key=Owner,Value=$OWNER_NAME --region $REGION
                           aws ec2 create-tags --resources $INSTANCE_ID --tags Key=CustomerName,Value=$CUST_NAME --region $REGION
                           echo "#####Please find the Instance details below######"
                           sleep 2
                           aws ec2 describe-instances --output table --region us-east-1  --instance-ids i-db76dcb1
                           echo "####Thank You####"
                           exit 0
                        fi
                else
                        echo "Try Again"
                        exit 0
                fi

;;
""| --help)
echo "Usage:./aws-vpc.sh --option"
echo "Options"
echo " --vpc							To crate VPC"
echo " --create-instance				To Crate a instance with in VPC"
echo "--help							Help"
;;
esac
