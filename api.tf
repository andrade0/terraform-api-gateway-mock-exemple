provider "aws" {
  region = "us-east-1"
}

resource "aws_api_gateway_rest_api" "FreeApi" {
  name        = "FreeApi"
  description = "This is my API for demonstration purposes"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

variable "storage" {
  type = string
}

resource "aws_api_gateway_resource" "ServerSection" {
  rest_api_id = aws_api_gateway_rest_api.FreeApi.id
  parent_id   = aws_api_gateway_rest_api.FreeApi.root_resource_id
  path_part   = "server-section"
}

resource "aws_api_gateway_method" "ServerSectionGet" {
  rest_api_id   = aws_api_gateway_rest_api.FreeApi.id
  resource_id   = aws_api_gateway_resource.ServerSection.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "ServerSectionGetIntegration" {
  rest_api_id = aws_api_gateway_rest_api.FreeApi.id
  resource_id = aws_api_gateway_resource.ServerSection.id
  http_method = aws_api_gateway_method.ServerSectionGet.http_method
  type        = "MOCK"
  request_templates = {
    "application/json" = "{ \"statusCode\": 200 }"
  }
}

resource "aws_api_gateway_method_response" "ServerSectionGetIntegrationResponse_200" {
  rest_api_id = aws_api_gateway_rest_api.FreeApi.id
  resource_id = aws_api_gateway_resource.ServerSection.id
  http_method = aws_api_gateway_method.ServerSectionGet.http_method
  status_code = 200
  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration_response" "ServerSectionGetIntegrationResponse" {
  rest_api_id = aws_api_gateway_rest_api.FreeApi.id
  resource_id = aws_api_gateway_resource.ServerSection.id
  http_method = aws_api_gateway_method.ServerSectionGet.http_method
  status_code = aws_api_gateway_method_response.ServerSectionGetIntegrationResponse_200.status_code
  response_templates = {
    "application/json" = <<EOF
{
  "blockTitle":"Server",
  "title":"Internet à toute vitesse",
  "blocs":[
    {
      "title":"La fibre la plus rapide",
      "description":"Regardez un film ou une série, téléchargez de la musique, transférez vos fichiers et vos photos, jouez en réseau. Tous vos usages à toute vitesse, en même temps et sans interruption.",
      "imageUri":"${var.storage}/active/hardware/v8-server-1.png",
      "specifications":[
        {
          "unit":"Gbit/s",
          "description":"en débit descendant",
          "value":"5",
          "limite":"Jusqu'a"
        },
        {
          "unit":"Gbit/s",
          "description":"en débit montant",
          "value":"1",
          "limite":"Jusqu'a"
        },
        {
          "unit":"fois",
          "description":"plus rapide que l'adsl",
          "value":"200",
          "limite":"Environ"
        }
      ]
    },
    {
      "title":"Connecté en Wi-Fi partout chez vous",
      "description":"Son WiFi Intelligent permet de gérer automatiquement votre réseau pour optimiser en temps réel les connexions sans fil de tous vos appareils (tablettes, ordinateurs, smartphones…). Utile en heure de pointes quand toute la famille connecte ses appareils en simultanée !",
      "hightlight":"Utile en heures de pointes quand toute la famille connecte ses appareils en simultanée !",
      "imageUri":"${var.storage}/active/hardware/v8-server-1.png"
    }
  ]
}
EOF
  }
}

resource "aws_api_gateway_deployment" "FreeApiDeployement" {
  rest_api_id = aws_api_gateway_rest_api.FreeApi.id
  depends_on = [aws_api_gateway_integration_response.ServerSectionGetIntegrationResponse]
}

resource "aws_api_gateway_stage" "FreeApiStageDev" {
  deployment_id = aws_api_gateway_deployment.FreeApiDeployement.id
  rest_api_id = aws_api_gateway_rest_api.FreeApi.id
  stage_name = "dev"
  depends_on = [aws_api_gateway_deployment.FreeApiDeployement]
}


output "section-url" {
  value = "${aws_api_gateway_stage.FreeApiStageDev.invoke_url}${aws_api_gateway_resource.ServerSection.path}"
}




