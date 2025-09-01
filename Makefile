SKIPCHECK ?= false
RAW_FORCE ?= false
MAIN_FORCE ?= false

.ONESHELL:
.SHELL := bash
.PHONY: raw push check-git-clean

check-git-clean:
	@set -euo pipefail; \
	if [ -n "$$(git status --porcelain)" ]; then \
		echo "存在未提交更改"; \
		git status --short; \
		exit 1; \
	fi

raw:
	@set -euo pipefail; \
	if [ "$(SKIPCHECK)" != "true" ]; then \
		$(MAKE) check-git-clean; \
	else \
		echo "skip check-git-clean"; \
	fi; \
	trap 'rm -rf "$$TMP_DEST" "$$TMP_TOML"' EXIT; \
	REPO_ROOT="$(CURDIR)"; \
	MAIN_BRANCH="main"; \
	RAW_BRANCH="raw"; \
	\
	echo "[1/9] 验证main分支存在..."; \
	git show-ref --verify --quiet refs/heads/$$MAIN_BRANCH >/dev/null 2>&1 || { echo "错误：主分支 $$MAIN_BRANCH 不存在"; exit 1; }; \
	\
	echo "[2/9] 创建临时目录..."; \
	TMP_DEST=$$(mktemp -d "$${TMPDIR:-/tmp}/chezmoidest.XXXXXX"); \
	TMP_TOML=$$(mktemp "$${TMPDIR:-/tmp}/chezmoconfig.XXXXXX.toml"); \
	\
	echo "[3/9] 生成临时toml配置文件..."; \
	touch "$$TMP_TOML"; \
	\
	echo "[4/9] chezmoi生成dotfiles"; \
	chezmoi init --apply --mode=file --exclude encrypted \
		--config "$$TMP_TOML" \
		--destination "$$TMP_DEST" || { echo "chezmoi执行失败"; exit 1; }; \
	\
	echo "[5/9] 重置raw分支..."; \
	(git show-ref --verify --quiet refs/heads/$$RAW_BRANCH && git checkout $$RAW_BRANCH) || git checkout --orphan $$RAW_BRANCH ;\
	git rm -rfq . >/dev/null 2>&1 || true; \
	\
	echo "[6/9] 迁移dotfiles..."; \
	rsync -a --delete --exclude .git "$$TMP_DEST/" "$$REPO_ROOT/" || { echo "文件同步失败"; exit 1; }; \
	\
	echo "[7/9] 提交变更..."; \
	git add -A && (git commit -m "$$(git rev-parse --short=7 main)" || echo "无变更需提交"); \
	\
	echo "[8/9] 清理临时资源..."; \
	rm -rf "$$TMP_DEST" "$$TMP_TOML"; \
	\
	echo "[9/9] 回到main分支..."; \
	git checkout $$MAIN_BRANCH; \
	echo "操作成功：raw 分支已重置为生成文件"

push: raw
	@set -euo pipefail; \
	if [ "$(MAIN_FORCE)" == "true" ]; then \
		echo "main->main(force)" &&
		git push origin main:main --force; \
	else \
		echo "main->main" &&
		git push origin main:main; \
	fi
	if [ "$(RAW_FORCE)" == "true" ]; then \
		echo "raw->raw(force)" &&
		git push origin raw:raw --force; \
	else \
		echo "raw->raw" &&
		git push origin raw:raw; \
	fi
