# Sourced by update-repo.sh (working directory = repo root).
# Requires components.env to be sourced first (SUITE, ARCHS, COMPONENTS).

# Ensure required directory structure and cache exist
for c in $COMPONENTS; do
  mkdir -p "pool/$c"
  for a in $ARCHS; do
    mkdir -p "dists/$SUITE/$c/binary-$a"
  done
done
mkdir -p .cache

# Write apt-ftparchive configs (kept in .cache, which is gitignored)
cat > .cache/generate.conf <<EOF
Dir {
  ArchiveDir ".";
  CacheDir "./.cache";
};

Default {
  Packages::Compress ". gzip";
};

TreeDefault {
  Directory "pool/\$(SECTION)";
  BinCacheDB "packages-\$(ARCH).db";
};

Tree "dists/$SUITE" {
  Sections "$COMPONENTS";
  Architectures "$ARCHS";
};
EOF

cat > .cache/release.conf <<EOF
APT::FTPArchive::Release::Origin "dev-jam";
APT::FTPArchive::Release::Label "dev-jam";
APT::FTPArchive::Release::Suite "$SUITE";
APT::FTPArchive::Release::Codename "$SUITE";
APT::FTPArchive::Release::Architectures "$ARCHS";
APT::FTPArchive::Release::Components "$COMPONENTS";
EOF
