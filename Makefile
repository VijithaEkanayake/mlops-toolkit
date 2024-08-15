# ENV Variables
APP_INSTANCE_URL?=http://localhost:10101
PYTEST_LOG=--log-cli-level=debug --log-format="%(asctime)s %(levelname)s [%(name)s:%(filename)s:%(lineno)d] %(message)s" --log-date-format="%Y-%m-%d %H:%M:%S"

venv:
	python3 -m venv venv
	./venv/bin/python3 -m pip install --upgrade pip

create-reports-dir:
	mkdir -p reports

.PHONY: setup
setup: venv
	./venv/bin/pip3 install -r requirements.txt

.PHONY: proto
proto: setup
	./venv/bin/python3 -m grpc_tools.protoc --proto_path=./ --python_out=./ --grpc_python_out=./ ./api/v1/proto/*.proto

.PHONY: run
run:
	./venv/bin/python3 mlops_data_fetcher.py

.PHONY: setup-docker
setup-docker: setup proto

.PHONY: setup-dev
setup-dev: setup setup-test setup-style proto

.PHONY: setup-test
setup-test: venv setup
	./venv/bin/pip3 install -r requirements-test.txt
	./venv/bin/playwright install

.PHONY: test-unit-ci
test-unit-ci: create-reports-dir
	PYTHONPATH=. \
	    ./venv/bin/pytest \
	    --cov-report xml:reports/coverage.xml \
	    --cov-report html:reports/htmlcov/ \
	    --junitxml=./reports/junit.xml \
		--cov=src \
		--full-trace \
		tests/unit/

.PHONY: test-e2e-ci
test-e2e-ci: create-reports-dir
	DEBUG=pw:api \
	PYTHONPATH=. \
	./venv/bin/pytest \
		$(PYTEST_LOG) -s \
		--hac-app-url=$(APP_INSTANCE_URL) \
		--junitxml=reports/junit-e2e.xml \
		--needs-hac-login \
		--video-path=reports \
		tests/e2e/ 2>&1 | tee reports/pytest-e2e.log

.PHONY: setup-style
setup-style: venv setup
	./venv/bin/pip3 install --no-cache-dir -r requirements-style.txt
	./venv/bin/pre-commit install --hook-type pre-commit --hook-type pre-push

.PHONY: check_format
check_format: #check which files will be reformatted
	./venv/bin/black --check .

.PHONY: format
format: #format files
	./venv/bin/black ./src ./tests

.PHONY: lint
lint: format
	./venv/bin/flake8 ./src ./tests

.PHONY: lint-ci
lint-ci: create-reports-dir
	./venv/bin/flake8 . > reports/flake8.log

.PHONY: test-e2e-remote
test-e2e-remote: create-reports-dir
	DEBUG=pw:api \
	PYTHONPATH=. \
	./venv/bin/pytest \
		$(PYTEST_LOG) -s \
		--hac-app-url=$(APP_INSTANCE_URL) \
		--headed
		--junitxml=reports/junit-e2e.xml \
		--log-cli-level=debug \
		--needs-hac-login \
		--video-path=reports \
		tests/e2e/

.PHONY: test-e2e-local
test-e2e-local: create-reports-dir
	DEBUG=pw:api \
	PYTHONPATH=. \
	./venv/bin/pytest \
		$(PYTEST_LOG) -s \
		--hac-app-url=$(APP_INSTANCE_URL) \
		--headed \
		--junitxml=reports/junit-e2e.xml \
		--video-path=reports \
		tests/e2e/ 2>&1 | tee reports/pytest-e2e.log

.PHONY: clean-app
clean-app:
	rm -rf app-data venv

.PHONY: clean-proto
clean-proto:
	rm -rf api/v1/proto/*.py

.PHONY: clean-ci
clean-ci:
	rm -rf reports

.PHONY: clean
clean: clean-app clean-ci clean-proto
