variable "name" {}
variable "widgets" {
  description = <<EOF
A dashboard is comprised of widgets. Each widget graphs some metrics and is located at some point (x,y) of the dashboard.
Defines the widgets to be created.
Example:
```
  widget_name = {
    row = 0
    column = 0
    metric_sets = { 
      name_of_metric_set = {
        dimensions = [id_of_the_resource_to_graph]
        metrics = { metric_name = { graph_specs = { "yAxis" = "left", "visible" = false , "label" = "some label"} } }
      }
    }
  }
``` 
A widget can contain many metric sets, from different sources/namespaces.
They are all show on the same widget.
EOF
}

variable "matrix" {
  default = {}
  description = <<EOF
Can be used to specify special sizes for a widget.
e.g.
```
matrix = {
  "1" = {
    "1" = { width = 15 }
  }
}
```
will make the 2 row, 2 column widget have a width of 15.
EOF

}

variable "rows" { default = 2 }
variable "columns" { default = 2 }

variable "row_height" { default = 12 }
#max column width is 24. Split in 12 for two columns, 8 for three etc
variable "column_width" { default = 12 }


variable "metric_sets" { 
  default = {} 
  description = "Can be used to add/override metric_sets"
}

variable "aws_region" {}