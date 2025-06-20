while true
do

  curl "http://$(terraform output -raw ecs_alb_api)/v3.1/nodes/atms?zip=14758&radius=10"

  sleep 5
done
