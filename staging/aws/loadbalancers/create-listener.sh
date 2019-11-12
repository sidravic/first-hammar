#!/bin/bash

function create_listener(){
    aws elbv2 create-listener  --load-balancer-arn $load_balancer_arn \
                           --protocol HTTPS \
                           --port 443 \
                           --default-actions Type=forward,TargetGroupArn=$target_group_arn \
                           --certificates CertificateArn=$AWS_CERTIFICATE_ARN \
                           --ssl-policy ELBSecurityPolicy-2016-08
                        
}

