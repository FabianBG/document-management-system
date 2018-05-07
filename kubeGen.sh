### $1 baseName $2 deployEnv $3 version $4 docker repo###
echo "Generando archivo ..."
echo "#Deployment
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  labels:
    app: $1
  name: $1
  namespace: $2
spec:
  replicas: 1
  selector:
    matchLabels:
      app: $1
  strategy:
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 1
    type: RollingUpdate
  template:
    metadata:
      labels:
        app: $1
    spec:
      volumes:
      - name: nfs-vol
        persistentVolumeClaim:
          claimName: nfs-claim
      containers:
      - image: "$4/$1:$3"
        imagePullPolicy: Always
        volumeMounts:
        - name: nfs-vol
          mountPath: /okmRepo
        env:
        - name: JAVA_OPTS
          value: -Dokm.db.jdbc=jdbc:postgresql://172.18.0.30:5432/alfa_openkm -Dokm.db.dirver=org.postgresql.Driver -Dokm.db.user=user_alfa_openkm -Dokm.db.password=SO*Wv#ma
        livenessProbe:
          failureThreshold: 5
          initialDelaySeconds: 30
          httpGet:
            path: /OpenKM
            port: 8080
            scheme: HTTP
        readinessProbe:
          failureThreshold: 3
          initialDelaySeconds: 30
          httpGet:
            path: /OpenKM
            port: 8080
            scheme: HTTP
        name: $1
        ports:
        - containerPort: 8080
          protocol: TCP
        resources:
          requests:
            memory: 800Mi
      imagePullSecrets:
      - name: yachay-harbor
      dnsPolicy: ClusterFirst
      restartPolicy: Always
      schedulerName: default-scheduler
      securityContext: {}
      terminationGracePeriodSeconds: 30
---
#Service
apiVersion: v1
kind: Service
metadata:
  labels:
    app: $1
  name: $1
  namespace: $2
spec:
  externalTrafficPolicy: Cluster
  ports:
  - nodePort:
    port: 8080
    protocol: TCP
  selector:
    app: $1
  sessionAffinity: ClientIP
  type: NodePort

---
#Ingress controller

apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  annotations:
    ingress.kubernetes.io/rewrite-target: /
    nginx.ingress.kubernetes.io/affinity: cookie
    nginx.ingress.kubernetes.io/session-cookie-hash: md5
    kubernetes.io/ingress.class: nginx
  name: $1
  namespace: $2
spec:
  rules:
  - host: $2-$1.yachay.gob.ec
    http:
      paths:
      - backend:
          serviceName: $1
          servicePort: 8080
        path: /" > $1.$2.yml;
