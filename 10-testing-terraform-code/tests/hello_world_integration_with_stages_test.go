package test

import (
	"fmt"
	http_helper "github.com/gruntwork-io/terratest/modules/http-helper"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/gruntwork-io/terratest/modules/test-structure"
	"strings"
	"testing"
	"time"
)

const databaseDirStage = "../live/stage/data-stores/mysql"
const helloAppDirStage = "../live/stage/services/hello-world-app"


func TestHelloWorldAppStageWithStages(t *testing.T) {
	t.Parallel()

	stage := test_structure.RunTestStage

	defer stage(t, "teardown_db", func() { teardownDb(t, databaseDirStage) })
	stage(t, "deploy_db", func() { deployDb(t, databaseDirStage) })

	defer stage(t, "teardown_app", func() { teardownApp(t, helloAppDirStage) })
	stage(t, "deploy_app", func() { deployApp(t, databaseDirStage, helloAppDirStage) })

	stage(t, "validate_app", func() { validateApp(t, helloAppDirStage) })
}

func deployDb(t *testing.T, dbDir string) {

	dbOpts := createDatabaseOpts(t, dbDir)

	// Save data to disk so that other test stages executed at a later
	// time can read the data back in
	test_structure.SaveTerraformOptions(t, dbDir, dbOpts)

	terraform.InitAndApply(t, dbOpts)
}

func createDatabaseOpts(t *testing.T, terraformDir string) *terraform.Options {
	uniqueId := random.UniqueId()

	bucketForTesting := "terraform-s3-bucket-ilia-example"
	bucketRegionForTesting := "us-east-2"

	dbStateKey := fmt.Sprintf("%s/%s/terraform.tfstate", t.Name(), uniqueId)

	return &terraform.Options{
		TerraformDir: terraformDir,
		Reconfigure:  true,

		Vars: map[string]interface{}{
			"db_name": fmt.Sprintf("test%s", uniqueId),
			"db_username": "admin",
			"db_password": "password",
		},

		BackendConfig: map[string]interface{}{
			"bucket":  bucketForTesting,
			"region":  bucketRegionForTesting,
			"key":     dbStateKey,
			"encrypt": true,
		},
	}
}

func teardownDb(t *testing.T, dbDir string) {
	dbOpts := test_structure.LoadTerraformOptions(t, dbDir)
	defer terraform.Destroy(t, dbOpts)
}

func deployApp(t *testing.T, dbDir string, helloAppDir string) {
	dbOpts := test_structure.LoadTerraformOptions(t, dbDir)
	helloOpts := createHelloAppOpts(dbOpts, helloAppDir)

	test_structure.SaveTerraformOptions(t, helloAppDir, helloOpts)

	terraform.InitAndApply(t, helloOpts)
}

func teardownApp(t *testing.T, appDir string) {
	helloOpts := test_structure.LoadTerraformOptions(t, appDir)
	defer terraform.Destroy(t, helloOpts)
}

func createHelloAppOpts(
	dbOpts *terraform.Options,
	terraformDir string) *terraform.Options {

	bucket := dbOpts.BackendConfig["bucket"].(string)
	region := "us-east-2" // тот же регион, что и в dbOpts
	key := fmt.Sprintf("%s-app/terraform.tfstate", dbOpts.Vars["db_name"])
	
	return &terraform.Options{
		TerraformDir: terraformDir,
		Reconfigure:  true,

		Vars: map[string]interface{}{
			"db_remote_state_bucket": dbOpts.BackendConfig["bucket"],
			"db_remote_state_key": dbOpts.BackendConfig["key"],
			"environment": dbOpts.Vars["db_name"],
		},

		BackendConfig: map[string]interface{}{
			"bucket":  bucket,
			"region":  region,
			"key":     key,
			"encrypt": true,
		},
	}
}

func validateApp(t *testing.T, helloAppDir string) {
	helloOpts := test_structure.LoadTerraformOptions(t, helloAppDir)
	validateHelloWorldApp(t, helloOpts)
}

func validateHelloWorldApp(t *testing.T, helloOpts *terraform.Options) {
	albDnsName := terraform.OutputRequired(t, helloOpts, "dns_name")
	url := fmt.Sprintf("http://%s", albDnsName)

	maxRetries := 10
	timeBetweenRetries := 10 * time.Second

	http_helper.HttpGetWithRetryWithCustomValidation(
		t, 
		url,
		nil,
		maxRetries,
		timeBetweenRetries,
		func(status int, body string) bool {
			return status == 200 &&
				strings.Contains(body, "Hello, World")
		},
	)
}

