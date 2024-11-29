    for i in {1..3000}
    do
      curl "$(terraform output -raw base_url)/confirmPayment?Name=Terraform?Name=Terraform" 
      sleep 1
    done