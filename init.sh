cat <<'EOF' | sudo tee /etc/profile.d/user.sh
USER_HOSTNAME=$(head -n1 /etc/hostname).localhost
export USER_HOSTNAME
EOF
