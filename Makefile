# дефолтное действие/цель - help :)
.DEFAULT_GOAL := help
# переменные с путями и версиями
#DH_USERNAME = имя DH пользователя или адрес репо
BBOX_PATH = monitoring/blackbox_exporter/
BBOX_VERSION = 1.0
DBE_PATH = monitoring/mongodb_exporter/
DBE_VERSION = 1.0
PROMETHEUS_PATH = monitoring/prometheus/
PROMETHEUS_VERSION = 1.0
ALERT_PATH = monitoring/alertmanager/
ALERT_VERSION = 1.0
COMMENT_PATH = src/comment/
COMMENT_VERSION = 1.0
POST_PATH = src/post-py/
POST_VERSION = 1.0
UI_PATH = src/ui/
UI_VERSION = 1.0
# цель №1 - выведи help
help:
# Волшебная строка ниже выводит описание целей
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-16s\033[0m %s\n", $$1, $$2}'
# основная цель для build, состоящая из списка целей
all: comment post ui blackbox-exporter mongodb-exporter prometheus alertmanager

# Перечисление подцелей из списка:
# По наличию ## формируется список для help, обязательная табуляция перед командой(mc двойной tab)
# build all
comment: ## Build comment
	docker build -t $(DH_USERNAME)/comment:$(COMMENT_VERSION) $(COMMENT_PATH)

post: ## Build post
	docker build -t $(DH_USERNAME)/post:$(POST_VERSION) $(POST_PATH)

ui: ## Build ui
	docker build -t $(DH_USERNAME)/ui:$(UI_VERSION) $(UI_PATH)

blackbox-exporter: ## Build blackbox_exporter
	docker build -t $(DH_USERNAME)/blackbox_exporter:$(BBOX_VERSION) $(BBOX_PATH)

mongodb-exporter: ## Build mongodb_exporter
	docker build -t $(DH_USERNAME)/mongodb_exporter:$(DBE_VERSION) $(DBE_PATH)

prometheus: ## Build prometheus
	docker build -t $(DH_USERNAME)/prometheus:$(PROMETHEUS_VERSION) $(PROMETHEUS_PATH)

alertmanager: ## Build alertmanager
	docker build -t $(DH_USERNAME)/alertmanager:$(ALERT_VERSION) $(ALERT_PATH)

# push all
pushall: push-comment push-post push-ui push-bbe push-mdbe push-pro
push-comment: ## push comment
	docker push $(DH_USERNAME)/comment:$(COMMENT_VERSION)

push-post: ## push post
	docker push $(DH_USERNAME)/post:$(POST_VERSION)

push-ui: ## push ui
	docker push $(DH_USERNAME)/ui:$(UI_VERSION)

push-bbe: ## push blackbox_exporter
	docker push $(DH_USERNAME)/blackbox_exporter:$(BBOX_VERSION)

push mdbe: ## push mongodb_exporter
	docker push $(DH_USERNAME)/mongodb_exporter:$(DBE_VERSION) $(DBE_PATH)

push-pro: ## push prometheus
	docker push $(DH_USERNAME)/prometheus:$(PROMETHEUS_VERSION)

push-ale: ## push alertmanager
	docker push $(DH_USERNAME)/alertmanager:$(ALERT_VERSION)

# run all
run-all: run-service run-monitoring
run-service: ## run service
	docker-compose -f docker/docker-compose.yml --env-file docker/.env up -d

run-monitoring: ## run monitoring
	docker-compose -f docker/docker-compose-monitoring.yml --env-file docker/.env up -d

# stop all
stop-all: stop-service stop-monitoring
stop-monitoring: ## stop monitoring
	docker-compose -f docker/docker-compose-monitoring.yml --env-file docker/.env down

stop-service: ## stop service
	docker-compose -f docker/docker-compose.yml --env-file docker/.env down
