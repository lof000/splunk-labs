


#while true
#do
#
#  curl http://example-lb-764122444.us-east-1.elb.amazonaws.com/v3.1/nodes/atms?zip=14758&radius=10
#
#  sleep 5
#done


for i in {1..3000}
do
  curl "$(terraform output -raw base_url)/confirmPayment?Name=Terraform?Name=Terraform" 
#  curl  "$(terraform output -raw base_url)/v3.1/nodes/atms?zip=14758&radius=10
  sleep 1
done