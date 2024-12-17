{{- define "sample-app.deployment" -}}
{{- $kind := index . 1 -}}
{{- with index . 0 -}}
{{- $values := mergeOverwrite (deepCopy .Values) (get .Values.apps $kind) | default dict -}}
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "sample-app.fullname" . }}-{{ $kind }}
  labels:
    {{- include "sample-app.labels.withKind" (list . $kind) | nindent 4 }}
spec:
  {{- if not $values.autoscaling.enabled }}
  replicas: {{ $values.replicas }}
  {{- end }}
  selector:
    matchLabels:
      {{- include "sample-app.selectorLabels.withKind" (list . $kind) | nindent 6 }}
  template:
    metadata:
      {{- with $values.podAnnotations }}
      annotations:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      labels:
        {{- include "sample-app.selectorLabels.withKind" (list . $kind) | nindent 8 }}
    spec:
      {{- with $values.imagePullSecrets }}
      imagePullSecrets:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      serviceAccountName: {{ include "sample-app.serviceAccountName" . }}
      securityContext:
        {{- toYaml $values.podSecurityContext | nindent 8 }}
      containers:
        - name: default
          securityContext:
            {{- toYaml $values.securityContext | nindent 12 }}
          image: '{{ $values.image.repository }}{{ if $values.image.tag | or (not (eq $values.image.tag "")) }}:{{ $values.image.tag | default .Chart.AppVersion }}{{- end }}'
          imagePullPolicy: {{ $values.image.pullPolicy }}
          args:
            {{- if not (hasPrefix "celeryworker" $kind) }}
            - {{ $kind }}
            - 'app'
            {{- else }}
            - 'celeryworker'
            - {{ (get .Values.apps $kind).queues | default (trimPrefix "celeryworker-" $kind) | join "," | toYaml }}
            - '-l'
            - {{ $values.celerylogLevel | default "info" | toString | toYaml }}
            {{- end }}
          envFrom:
            - configMapRef:
                name: {{ include "sample-app.fullname" . }}-env
            - secretRef:
                name: {{ include "sample-app.fullname" . }}-env
          ports:
            - name: http
              containerPort: 8080
              protocol: TCP
          resources:
            {{- toYaml $values.resources | nindent 12 }}
          {{- if not (hasPrefix "celeryworker" $kind) }}
          livenessProbe:
            httpGet:
              path: '/.genki'
              port: http
            initialDelaySeconds: 3
            periodSeconds: 30
          readinessProbe:
            httpGet:
              path: '/.genki'
              port: http
            initialDelaySeconds: 3
            periodSeconds: 30
          {{- end }}
          volumeMounts:
            - mountPath: /tmp
              name: temporary
      {{- with $values.nodeSelector }}
      nodeSelector:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with $values.affinity }}
      affinity:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with $values.tolerations }}
      tolerations:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      volumes:
        - name: temporary
          emptyDir:
            sizeLimit: {{ $values.temporaryDirectory.sizeLimit }}
{{- end }}
{{- end }}