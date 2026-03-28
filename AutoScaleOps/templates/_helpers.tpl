{{- define "autoscaleops.name" -}}
{{- .Chart.Name | lower -}}
{{- end -}}

{{- define "autoscaleops.fullname" -}}
{{- printf "%s-%s" .Release.Name (.Chart.Name | lower) | trunc 63 | trimSuffix "-" -}}
{{- end -}}
