#!/bin/sh

cat >install-cbas-client-hooks.sh <<EOF
#!/bin/sh

rm .git/hooks/*

cat >.git/hooks/commit-msg <<'FOO'
$(cat client/commit-msg-trac)
FOO

cat >.git/hooks/post-checkout <<'FOO'
$(cat client/post-checkout-rebase)
FOO

EOF

