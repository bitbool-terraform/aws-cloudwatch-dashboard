locals {

  # matrix is [row][column]

  ## First create a hash with the widths and heights.
  ## Default (var.row_height and var.column_width), overridden by the provided var.matrix possible values
  matrix_sizes = { for row in range(var.rows): tostring(row) => {
      for column in range(var.columns): tostring(column) => {
        width = lookup(lookup(lookup(var.matrix,tostring(row),{}),tostring(column),{}),"width",var.column_width)
        height = lookup(lookup(lookup(var.matrix,tostring(row),{}),tostring(column),{}),"height",var.row_height)
      }
    }
  }

  ## Then calculate the x,y position of each widget, based on the above sizes.
  ## e.g widget ["2","3"], 3rd row, 4th column (matrix starts at [0,0]) has 
  ##  * 3 widgets/columns on its left ([2,0],[2,1],[2,2]) since it is on the 4th column 
  ##  * 2 widgets/rows on its top ([0,3],[1,3]) since it is on the 3 row.
  ## Therefore,
  ## x = widget[2][0].width + widget[2][1].width + widget[2][2].width
  ## y = widget[0][3].height + widget[1][3].height
  ## The result is matrix that has width, height (already calculated above) and x,y for each widget
  matrix = { for row in range(var.rows): tostring(row) => {
      for column in range(var.columns): tostring(column) => {
        width = local.matrix_sizes[tostring(row)][tostring(column)].width
        height = local.matrix_sizes[tostring(row)][tostring(column)].height
        x = sum(concat([for i in range(column): local.matrix_sizes[tostring(row)][tostring(i)].width ],[0]))
        y = sum(concat([for i in range(row): local.matrix_sizes[tostring(i)][tostring(column)].height ],[0]))
      }
    }
  }


  ## The json object for the dashboard.
  widgets = [ for key,widget in var.widgets: {
      type = lookup(widget,"type","metric")
      x = local.matrix[tostring(widget.row)][tostring(widget.column)].x
      y = local.matrix[tostring(widget.row)][tostring(widget.column)].y
      width = local.matrix[tostring(widget.row)][tostring(widget.column)].width
      height = local.matrix[tostring(widget.row)][tostring(widget.column)].height
      properties = {
        title = key
        view    = lookup(widget,"view","timeSeries")
        stacked = lookup(widget,"stacked",false)
        region  = lookup(widget,"region",var.aws_region)
        period  = lookup(widget,"period",120)
        stat    = lookup(widget,"stat","Average")
        metrics = concat([ for metrics_set_key,metrics_set_value in widget.metric_sets: [
            for metric_key,metric_value in merge(local.metric_sets[metrics_set_value.set_id].metrics,lookup(metrics_set_value,"metrics",{})): flatten([
                local.metric_sets[metrics_set_value.set_id].namespace,
                metric_key,
                local.metric_sets[metrics_set_value.set_id].dimension_name,
                metrics_set_value.dimensions,
                merge(
                  { label = format("%s%s",try(format("%s ",metrics_set_value.label_prefix),""),lookup(metric_value,"label",metric_key)) },
                  lookup(metric_value,"graph_specs",{})
                )
              ])
            ]
          ]...)
      }
    }
  ]

}


resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = var.name

  dashboard_body = jsonencode({
    widgets = local.widgets
  })
}

