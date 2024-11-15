all: main.go
	go build -o .output/main main.go
	chmod +x .output/main
	syft scan file:.output/main -o spdx-json=sboms/sbom-go-spdx.json --source-name sbom-example --source-version v0.0.1
	syft scan file:.output/main -o cyclonedx-json=sboms/sbom-go-cyclonedx.json --source-name sbom-example --source-version v0.0.1
	grype sbom:.output/cyclonedx.json -o cyclonedx-json=sboms/sbom-go-cyclonedx.grype.json
	grype sbom:.output/cyclonedx.json -o sarif=sboms/sarif.json

docker:
	docker build -t sbom:v0.0.1 .

sbom:
	syft scan sbom:v0.0.1 -o spdx-json=sboms/docker/sbom-go-spdx.json
	syft scan sbom:v0.0.1 -o cyclonedx-json=sboms/docker/sbom-go-cyclonedx.json
	grype sbom:sboms/docker/cyclonedx.json -o cyclonedx-json=sboms/docker/sbom-go-cyclonedx.grype.json
	grype sbom:sboms/docker/cyclonedx.json -o sarif=sboms/docker/sarif.json

novex:
	docker scout cves sbom:v0.0.1

vex:
	docker scout cves sbom:v0.0.1 --vex-location vex.json

.PHONY: clean

clean:
	rm -rf .output