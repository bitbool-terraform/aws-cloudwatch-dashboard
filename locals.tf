locals {

  ### MEtric Sets
  ## For each metric in a metric set a row in the widget is created:
  ## namespace, metric (key), dimension_name, dimension(provided by the caller, identifies the asset)
  ## metrics can be overriden/added by widgets.metric_sets[metric_set_name].[metric].... 

  buildin_metric_sets = {
    cloudfront_requests = {
      namespace = "AWS/CloudFront"
      dimension_name = ["Region", "Global", "DistributionId"]
      metrics = {
        "5xxErrorRate" = { graph_specs = { "yAxis" = "left"} }
        "4xxErrorRate" = { graph_specs = { "yAxis" = "left"} }
        "TotalErrorRate" = { graph_specs = { "yAxis" = "left"} }
        "Requests" = { graph_specs = { "yAxis" = "right", stat = "Sum" } }
      }
    }
    cloudfront_bytes = {
      namespace = "AWS/CloudFront"
      dimension_name = ["Region", "Global", "DistributionId"]
      metrics = {
        "BytesDownloaded" = { graph_specs = { "yAxis" = "right"} }
        "BytesUploaded" = { graph_specs = { "yAxis" = "right" } }
      }
    }    
    alb = {
      namespace = "AWS/ApplicationELB"
      dimension_name = ["LoadBalancer"]
      metrics = {
        "TargetResponseTime" = { graph_specs = { "yAxis" = "left"} }
        "RequestCount" = { graph_specs = {"stat": "Sum", "yAxis" = "right"} }
        "ActiveConnectionCount" = { graph_specs = { "yAxis" = "right" } }
        "NewConnectionCount" = { graph_specs = { "yAxis" = "right" } }
        "HTTPCode_Target_2XX_Count" = { graph_specs = { "yAxis" = "right" } }
        "HTTPCode_Target_4XX_Count" = { graph_specs = { "yAxis" = "right", "visible" = false } }
        "HTTPCode_Target_5XX_Count" = { graph_specs = { "yAxis" = "right", "visible" = false } }
        "HTTPCode_ELB_5XX_Count" = { graph_specs = { "yAxis" = "right"} }
      }      
    }
    ec2_scalingGroup_cpu = {
      namespace = "AWS/EC2"
      dimension_name = ["AutoScalingGroupName"]
      metrics = {
        "CPUUtilization" = { graph_specs = { "yAxis" = "right" } }    
      }  
    }
    cwagent_memory = {
      namespace = "CWAgent"
      dimension_name = []
      metrics = {
        "mem_used_percent" = { "label": "Memory Used %", graph_specs = { "stat": "Maximum" } }    
      }  
    }
    route53healthCheck = {
      namespace = "AWS/Route53"
      dimension_name = ["HealthCheckId"]
      metrics = {
        "HealthCheckStatus" = { }    
      }  
    }
    rds = {
      namespace = "AWS/RDS"
      dimension_name = ["DBInstanceIdentifier"]
      metrics = {
        "ReadIOPS" = {}
        "DatabaseConnections" = {}
        "FreeableMemory" = { graph_specs = { "yAxis" = "right" } }
        "FreeStorageSpace" = { graph_specs = { "yAxis" = "right" } }
        "DiskQueueDepth" = {}
        "CPUUtilization" = {}
        "WriteIOPS" = {}
      }      
    }
  }

  metric_sets = merge(local.buildin_metric_sets,var.metric_sets)

}

