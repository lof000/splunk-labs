while true
do
  #curl http://ledeoliv-ecs-lb-280855846.us-east-1.elb.amazonaws.com/v3.1/nodes/atms?zip=14758&radius=10
  curl http://example-lb-764122444.us-east-1.elb.amazonaws.com/v3.1/nodes/atms?zip=14758&radius=10

  sleep 5
done
