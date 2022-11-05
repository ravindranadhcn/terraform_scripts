# terraform_scripts
This terraform script will create devopsvpc and public subnet with Internet gateway, Route table with subnet assosiation, Security group to allow ssh from any where and EC2 surver with keypair.itii


you have to add creadetials file with working access key and secret access key.
And also please add public key in main.tf file in aws_key_pair section.

cat ~/.aws/credentials 
[default]
aws_access_key_id = xxxxxxxxxxxxxxxxxxxxx
aws_secret_access_key = XXXXXXXXXXXXXXXXXXXXXXXXXXX
ravindranadhcn@RavindranadhsMBPM ~ % 


 
