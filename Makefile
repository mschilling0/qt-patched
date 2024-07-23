GIT_URL := https://github.com/mschilling0

QT_IMAGE_REPO := qt/building
QT_IMAGE_TAG := 0.1
QT_IMAGE := ${QT_IMAGE_REPO}:${QT_IMAGE_TAG}

QT_VERSION := 5.15.9
QT_REPO_NAME := qt-patched

USE_BUILDKIT := 1

all: build-qt

clean: clean-qt clean-qt-artifact

QT_ARTIFACT=${QT_REPO_NAME}-${QT_VERSION}.tar.gz

.PHONY: build-qt
build-qt: ${QT_ARTIFACT}
	@DOCKER_BUILDKIT=${USE_BUILDKIT} docker build --file Dockerfile \
		--build-arg "QT_VERSION=${QT_VERSION}" \
		--tag "${QT_IMAGE}" .

.PHONY: clean-qt
clean-qt:
	@docker image rm "${QT_IMAGE}"

# Clone and package qt repository
${QT_ARTIFACT}:
	@git clone --depth 1 --branch "qt-${QT_VERSION}" \
		"${GIT_URL}/${QT_REPO_NAME}.git"
	@( \
		cd "${QT_REPO_NAME}" && \
		tar -czf "${QT_ARTIFACT}" qt* && \
		mv "${QT_ARTIFACT}" .. \
		)
	@rm -rf "${QT_REPO_NAME}"

clean-qt-artifact:
	@rm -f "${QT_ARTIFACT}"
