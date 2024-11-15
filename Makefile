all: main.go
	go build -o .output/main main.go
	chmod +x .output/main
	syft scan file:.output/main -o spdx-json=.output/sbom-go-spdx.json --source-name sbom-example --source-version v0.0.1
	syft scan file:.output/main -o cyclonedx-json=.output/sbom-go-cyclonedx.json --source-name sbom-example --source-version v0.0.1
	grype sbom:.output/cyclonedx.json -o cyclonedx-json=.output/sbom-go-cyclonedx.grype.json
	grype sbom:.output/cyclonedx.json -o sarif=.output/sarif.json

docker:
	docker build -t sbom:v0.0.1 .

sbom:
	syft scan sbom:v0.0.1 -o spdx-json=.output/docker/spdx.json
	syft scan sbom:v0.0.1 -o cyclonedx-json=.output/docker/cyclonedx.json
	grype sbom:.output/docker/cyclonedx.json -o cyclonedx-json=.output/docker/cyclonedx.grype.json
	grype sbom:.output/docker/cyclonedx.json -o sarif=.output/docker/sarif.json

novex:
	docker scout cves sbom:v0.0.1

vex:
	docker scout cves sbom:v0.0.1 --vex-location vex.json

.PHONY: clean

clean:
	rm -rf .output