{{- define "sample-app.service" -}}
{{- $kind := index . 1 -}}
{{- with index . 0 -}}
{{- $values := mergeOverwrite (deepCopy .Values) (get .Values.apps $kind) | default dict -}}
{{- if (not (hasPrefix "celeryworker" $kind)) | and $values.service.enabled }}
---
apiVersion: v1
kind: Service
metadata:
  name: {{ $values.service.name | default (include "sample-app.fullname" .) }}
  labels:
    {{- include "sample-app.labels.withKind" (list . $kind) | nindent 4 }}
spec:
  type: {{ $values.service.type }}
  ports:
    - port: {{ $values.service.port }}
      targetPort: http
      protocol: TCP
      name: http
  selector:
    {{- include "sample-app.selectorLabels.withKind" (list . $kind) | nindent 4 }}
{{- end }}
{{- end }}
{{- end }}