#!/bin/bash

export AIGW_PORT="8080"

echo "Starting the Gloo AI Gateway Semantic Cache Demo..."
echo

# Step 1: Configure a simple route to openai LLM backend
read -p "Step 1: Configure a simple route to openai LLM backend. Press enter to proceed..."
kubectl create secret generic openai-secret -n gloo-system \
--from-literal="Authorization=Bearer $OPENAI_API_KEY" \
--dry-run=client -oyaml | kubectl apply -f -
kubectl apply -f route
echo
cat route/*.yaml
echo
echo "Route applied successfully."
echo

# Step 2: Get AI Gateway Load Balancer Address
read -p "Step 2: Retrieve the AI Gateway Load Balancer address. Press enter to proceed..."
export GATEWAY_IP=$(kubectl get svc -n gloo-system gloo-proxy-ai-gateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}{.status.loadBalancer.ingress[0].hostname}')
echo "Gateway IP: $GATEWAY_IP"
echo

# Step 3: Test OpenAI endpoint with the "Hi" use case
echo
echo "Testing OpenAI endpoint with the "Hi" use case."

while true; do
  read -p "Press Enter to send a request, or type 'next' to move on: " user_input
  if [[ "$user_input" == "next" ]]; then
    echo "Exiting test."
    break
  fi

  echo "Sending request to OpenAI endpoint..."
  curl -i http://$GATEWAY_IP:$AIGW_PORT/openai -H "Content-Type: application/json" -d '{
      "model": "gpt-4o-mini",
      "messages": [
        {
          "role": "user",
          "content": "Hi"
        }
      ]
    }'
  echo
  echo "Responses should come from gpt-4o-mini model."
  echo
done

# Step 4: Test OpenAI endpoint with service mesh prompt
echo
echo "Testing OpenAI endpoint with service mesh prompt."

while true; do
  read -p "Press Enter to send a request, or type 'next' to move on: " user_input
  if [[ "$user_input" == "next" ]]; then
    echo "Exiting test."
    break
  fi

  echo "Sending request to OpenAI endpoint..."
  curl -i http://$GATEWAY_IP:$AIGW_PORT/openai -H "Content-Type: application/json" -d '{
      "model": "gpt-4o-mini",
      "messages": [
        {
          "role": "system",
          "content": "You are a solutions architect for Kubernetes networking, skilled in explaining complex technical concepts surrounding API Gateway, Service Mesh, and CNI"
        },
        {
          "role": "user",
          "content": "Write me a 20-word pitch on why I should use a service mesh in my Kubernetes cluster"
        }
      ]
    }'
  echo
  echo "Responses should come from gpt-4o-mini model."
  echo
done