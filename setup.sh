#!/usr/bin/bash
is_container() {
  [[ -f "/run/.containerenv" || -f "/run/.toolboxenv" || -f "/.dockerenv" ]]
}

if ! is_container || [[ "$CONTAINER_NAME" != "nyoom-container" ]]; then
  echo "Not running outside container 'nyoom-container'."
  exit 1
fi

export COMMIT_DATE=${1:-2022-12-01}
echo $COMMIT_DATE

[[ -d "$HOME/.config/nvim" ]] || mkdir -p "$HOME/.config"
[[ -f $HOME/.config/nvim/bin/nyoom ]] || git clone https://github.com/nyoom-engineering/nyoom.nvim.git "$HOME/.config/nvim"
COMMIT=$(git -C "$HOME/.config/nvim" rev-list -n 1 --before="$COMMIT_DATE" --first-parent HEAD)
git -C $HOME/.config/nvim config advice.detachedHead false

# Checkout that commit
echo checking out commit
pushd "$HOME/.config/nvim" || exit
git checkout -f "$COMMIT"
# git restore bin/nyoom #otherwise sed commands below will keep inserting multiple checkouts
# git restore fnl/modules/tools/tree-sitter/init.fnl
#wget https://raw.githubusercontent.com/boydkelly/nyoom.nvim/main/bin/nyoom -O bin/nyoom
sed -i '2iCOMMIT_DATE="${COMMIT_DATE}"' bin/nyoom
sed -i '/git clone/ s/--depth 1//g; /git clone/ s/ -q//g; /git clone/ s/ -b nightly --single-branch//g' bin/nyoom

sed -i '/git clone.*packer/a\
COMMIT=$(git -C "${DATA_PATH}/site/pack/packer/opt/packer.nvim" rev-list -n 1 --before="$COMMIT_DATE" --first-parent HEAD) && \
pushd "${DATA_PATH}/site/pack/packer/opt/packer.nvim" >/dev/null && \
echo "Checking out packer.nvim at $COMMIT" && \
git config advice.detachedHead false && \
git checkout "$COMMIT" && \
popd >/dev/null' bin/nyoom

sed -i '/git clone.*hotpot/a\
COMMIT=$(git -C "${DATA_PATH}/site/pack/packer/start/hotpot.nvim" rev-list -n 1 --before="$COMMIT_DATE" --first-parent HEAD) && \
pushd "${DATA_PATH}/site/pack/packer/start/hotpot.nvim" >/dev/null && \
echo "Checking out hotpot.nvim at $COMMIT" && \
git config advice.detachedHead false && \
git checkout "$COMMIT" && \
popd >/dev/null' bin/nyoom

#get tree-sitter commit first
git clone --filter=blob:none --no-checkout --single-branch --depth=100 \
  https://github.com/nyoom-engineering/nyoom.nvim.git /tmp/treesitter
TSCOMMIT=$(git -C /tmp/treesitter rev-list -n 1 --before="$COMMIT_DATE" --first-parent HEAD)

# sed -i "/cmd/i\\
# :commit $TSCOMMIT" fnl/modules/tools/tree-sitter/init.fnl
sed -i "/tools\.tree-sitter/a\\
:commit \"$TSCOMMIT\"
" fnl/modules/tools/tree-sitter/init.fnl

#disable problematic notify
# sed -i 's/^\(\bnotify\b)$/;; \1/' fnl/modules.fnl
# sed -i '/:setup (fn \[\]/i:commit "a1b6c9e"' modules/ui/noice/init.fnl
bin/nyoom install
bin/nyoom sync
popd || exit
