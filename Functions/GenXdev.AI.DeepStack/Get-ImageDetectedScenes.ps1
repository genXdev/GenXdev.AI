<##############################################################################
Part of PowerShell module : GenXdev.AI.DeepStack
Original cmdlet filename  : Get-ImageDetectedScenes.ps1
Original author           : René Vaessen / GenXdev
Version                   : 2.1.2025
################################################################################
Copyright (c)  René Vaessen / GenXdev

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
################################################################################>
###############################################################################
<#
.SYNOPSIS
Classifies an image into one of 365 scene categories using DeepStack.

.DESCRIPTION
This function analyzes an image file to classify it into one of 365 different
scene categories. It uses a local DeepStack scene recognition API running on a
configurable port and returns the scene classification with confidence score.
The function supports GPU acceleration and Docker container management.

.PARAMETER ImagePath
The local path to the image file to analyze. This parameter accepts any valid
file path that can be resolved by the system.

.PARAMETER NoDockerInitialize
Skip Docker initialization when this switch is used. This is typically used
when already called by parent function to avoid duplicate initialization.

.PARAMETER Force
Force rebuild of Docker container and remove existing data when this switch
is used. This is useful for troubleshooting or updating the DeepStack image.

.PARAMETER UseGPU
Use GPU-accelerated version when this switch is used. This requires an
NVIDIA GPU with proper Docker GPU support configured.

.PARAMETER ContainerName
The name for the Docker container. This allows multiple DeepStack instances
or custom naming conventions. Default is "deepstack_face_recognition".

.PARAMETER VolumeName
The name for the Docker volume for persistent storage. This ensures face data
persists between container restarts. Default is "deepstack_face_data".

.PARAMETER ServicePort
The port number for the DeepStack service. Must be between 1 and 65535.
Default is 5000.

.PARAMETER HealthCheckTimeout
Maximum time in seconds to wait for service health check. Must be between 10
and 300 seconds. Default is 60.

.PARAMETER HealthCheckInterval
Interval in seconds between health check attempts. Must be between 1 and 10
seconds. Default is 3.

.PARAMETER ImageName
Custom Docker image name to use instead of the default DeepStack image. This
allows using custom or updated DeepStack images.

.EXAMPLE
Get-ImageDetectedScenes -ImagePath "C:\Users\YourName\landscape.jpg"
Classifies the scene in the specified image using default settings.

.EXAMPLE
Get-ImageDetectedScenes -ImagePath "C:\photos\vacation.jpg" -ConfidenceThreshold 0.6 -UseGPU
Classifies the scene using GPU acceleration and only accepts results with confidence >= 60%.

.EXAMPLE
Get-ImageDetectedScenes -ImagePath "C:\photos\vacation.jpg" -UseGPU
Classifies the scene using GPU acceleration for faster processing.

.EXAMPLE
"C:\Users\YourName\beach.jpg" | Get-ImageDetectedScenes
Pipeline support for processing multiple images.

.NOTES
DeepStack API Documentation: POST /v1/vision/scene endpoint for scene
recognition.
Example: curl -X POST -F "image=@landscape.jpg"
http://localhost:5000/v1/vision/scene

Scene categories include places like: abbey, airplane_cabin, airport_terminal,
alley, amphitheater, amusement_arcade, amusement_park, anechoic_chamber,
apartment_building, aquarium, aqueduct, arcade, arch, archive, art_gallery,
art_school, art_studio, assembly_line, athletic_field, atrium, attic,
auditorium, auto_factory, badlands, balcony, ball_pit, ballroom,
bamboo_forest, banquet_hall, bar, barn, barndoor, baseball_field, basement,
basilica, basketball_court, bathroom, bathtub, battlefield, beach,
beauty_salon, bedroom, berth, biology_laboratory, boardwalk, boat_deck,
boathouse, bookstore, booth, botanical_garden, bowling_alley, boxing_ring,
bridge, building_facade, bullring, burial_chamber, bus_interior,
bus_station, butchers_shop, butte, cabin, cafeteria, campsite, campus,
canal, candy_store, canyon, car_interior, castle, catacomb, cemetery,
chalet, chemistry_lab, chinatown, church, classroom, clean_room, cliff,
cloister, closet, clothing_store, coast, cockpit, coffee_shop,
computer_room, conference_center, conference_room, construction_site,
corn_field, corridor, cottage, courthouse, courtyard, creek, crevasse,
crosswalk, dam, delicatessen, department_store, desert, diner, dining_hall,
dining_room, discotheque, dock, doorway, dorm_room, downtown, driveway,
drugstore, elevator, engine_room, entrance_hall, escalator, excavation,
fabric_store, farm, fastfood_restaurant, field, fire_escape, fire_station,
fishpond, flea_market, florist_shop, food_court, football_field, forest,
forest_path, forest_road, formal_garden, fountain, galley, game_room,
garage, garbage_dump, gas_station, gazebo, general_store, gift_shop,
glacier, golf_course, greenhouse, grotto, gymnasium, hangar, harbor,
hardware_store, hayfield, heliport, highway, home_office, home_theater,
hospital, hospital_room, hot_spring, hotel, hotel_room, house,
hunting_lodge, ice_cream_parlor, ice_rink, ice_shelf, iceberg, igloo,
industrial_area, inn, islet, jacuzzi, jail_cell, japanese_garden,
jewelry_shop, junkyard, kasbah, kennel, kindergarten_classroom, kitchen,
lagoon, lake, laundromat, lawn, lecture_room, legislature, library,
lighthouse, living_room, lobby, lock_chamber, locker_room, mansion,
manufactured_home, market, marsh, martial_arts_gym, mausoleum, medina,
moat, monastery, mosque, motel, mountain, mountain_path, mountain_snowy,
movie_theater, museum, music_studio, nursery, nursing_home, oast_house,
ocean, office, office_building, oil_refinery, oilrig, operating_room,
orchard, orchestra_pit, pagoda, palace, pantry, park, parking_garage,
parking_lot, pasture, patio, pavilion, pharmacy, phone_booth,
physics_laboratory, picnic_area, pier, pizzeria, playground, playroom,
plaza, pond, porch, promenade, pub, public_pool, racecourse, raceway,
raft, railroad_track, rainforest, reception, recreation_room,
residential_neighborhood, restaurant, restaurant_kitchen,
restaurant_patio, rice_paddy, river, rock_arch, rope_bridge, ruin,
runway, sandbox, sauna, schoolhouse, science_museum, server_room, shed,
shoe_shop, shopfront, shopping_mall, shower, ski_resort, ski_slope, sky,
skyscraper, slum, snowfield, soccer_field, stable, stadium, stage,
staircase, storage_room, storm_cellar, street, strip_mall,
subway_station, supermarket, swamp, swimming_hole, swimming_pool,
synagogue, television_room, television_studio, temple, throne_room,
ticket_booth, topiary_garden, tower, toyshop, track, train_interior,
train_station, tree_farm, tree_house, trench, tundra, underwater,
university, upholstery_shop, urban_canal, valley, vegetable_garden,
veterinarians_office, viaduct, village, vineyard, volcano,
volleyball_court, waiting_room, water_park, water_tower, waterfall,
watering_hole, wave, wet_bar, wheat_field, wind_farm, windmill, yard,
youth_hostel, zen_garden.
###############################################################################>
function Get-ImageDetectedScenes {

    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '')]

    param(
        #######################################################################
        [Parameter(
            Position = 0,
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'The local path to the image file to analyze'
        )]        [ValidateNotNullOrEmpty()]
        [string] $ImagePath,
        #######################################################################
        [Parameter(
            Position = 1,
            Mandatory = $false,
            HelpMessage = ('Minimum confidence threshold (0.0-1.0). ' +
                'Default is 0.0')
        )]
        [ValidateRange(0.0, 1.0)]
        [double] $ConfidenceThreshold = 0.0,
        #######################################################################
        [Parameter(
            Position = 2,
            Mandatory = $false,
            HelpMessage = 'The name for the Docker container'
        )]
        [ValidateNotNullOrEmpty()]
        [string] $ContainerName = 'deepstack_face_recognition',
        #######################################################################
        [Parameter(
            Position = 3,
            Mandatory = $false,
            HelpMessage = ('The name for the Docker volume for persistent ' +
                'storage')
        )]
        [ValidateNotNullOrEmpty()]
        [string] $VolumeName = 'deepstack_face_data',
        #######################################################################
        [Parameter(
            Position = 4,
            Mandatory = $false,
            HelpMessage = 'The port number for the DeepStack service'
        )]
        [ValidateRange(1, 65535)]
        [int] $ServicePort = 5000,
        #######################################################################
        [Parameter(
            Position = 5,
            Mandatory = $false,
            HelpMessage = ('Maximum time in seconds to wait for service ' +
                'health check')
        )]
        [ValidateRange(10, 300)]
        [int] $HealthCheckTimeout = 60,
        #######################################################################
        [Parameter(
            Position = 6,
            Mandatory = $false,
            HelpMessage = ('Interval in seconds between health check ' +
                'attempts')
        )]
        [ValidateRange(1, 10)]
        [int] $HealthCheckInterval = 3,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Custom Docker image name to use'
        )]
        [ValidateNotNullOrEmpty()]
        [string] $ImageName,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Skip Docker initialization (used when already ' +
                'called by parent function)')
        )]
        [switch] $NoDockerInitialize,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Force rebuild of Docker container and remove ' +
                'existing data')
        )]
        [Alias('ForceRebuild')]
        [switch] $Force,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Use GPU-accelerated version (requires NVIDIA ' +
                'GPU)')
        )]
        [switch] $UseGPU,
        ###################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Show Docker Desktop window during initialization'
        )]
        [Alias('sw')]
        [switch]$ShowWindow
        ###################################################################
    )
    begin {
        # use script-scoped variables set by ensuredeepstack, with fallback
        # defaults
        if (-not $ApiBaseUrl) {

            $NoDockerInitialize = $false
        }

        # set the confidence threshold for filtering scene recognition results
        $script:ConfidenceThreshold = $ConfidenceThreshold

        # ensure that the deepstack scene recognition service is running
        if (-not $NoDockerInitialize) {

            Microsoft.PowerShell.Utility\Write-Verbose `
            ('Ensuring DeepStack scene recognition service is ' +
                'available')

            # copy parameter values for the ensuredeepstack function call
            $ensureParams = GenXdev.FileSystem\Copy-IdenticalParamValues `
                -BoundParameters $PSBoundParameters `
                -FunctionName 'GenXdev.AI\EnsureDeepStack' `
                -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable `
                    -Scope Local `
                    -ErrorAction SilentlyContinue)

            # initialize deepstack docker container if needed
            $null = GenXdev.AI\EnsureDeepStack @ensureParams

        } else {

            Microsoft.PowerShell.Utility\Write-Verbose `
                'Skipping Docker initialization as requested'
        }

        Microsoft.PowerShell.Utility\Write-Verbose `
            "Using DeepStack scene recognition API at: $script:ApiBaseUrl"

        #######################################################################
        <#
        .SYNOPSIS
        Processes the scene recognition result from DeepStack API.

        .DESCRIPTION
        This helper function takes the raw response from the DeepStack scene
        recognition API and formats it into a standardized output object with
        scene label, confidence score, and success status.

        .PARAMETER SceneData
        The raw scene data response from the DeepStack API containing the
        scene classification results.

        .EXAMPLE
        $result = Format-SceneResult -SceneData $response
        #>
        function Format-SceneResult {

            param($SceneData)

            # check if scene data is valid and successful
            if (-not $SceneData -or -not $SceneData.success) {

                Microsoft.PowerShell.Utility\Write-Verbose `
                    'No successful scene data received'

                return @{
                    success    = $false
                    scene      = 'unknown'
                    confidence = 0.0
                    message    = 'Scene recognition failed'
                }
            }

            # extract scene classification results
            $scene = if ($SceneData.label) {
                $SceneData.label
            } else {
                'unknown'
            }

            $confidence = if ($SceneData.confidence) {
                $SceneData.confidence
            } else {
                0.0
            }

            Microsoft.PowerShell.Utility\Write-Verbose `
                "Detected scene: $scene (confidence: $confidence)"

            # check if confidence meets the threshold
            if ($confidence -lt $script:ConfidenceThreshold) {
                Microsoft.PowerShell.Utility\Write-Verbose `
                    "Scene confidence $confidence below threshold $($script:ConfidenceThreshold), marking as unknown"

                return @{
                    success               = $false
                    scene                 = 'unknown'
                    label                 = 'unknown'
                    confidence            = $confidence
                    confidence_percentage = [math]::Round($confidence * 100, 2)
                    message               = 'Scene confidence below threshold'
                }
            }

            return @{
                success               = $true
                scene                 = $scene
                label                 = $scene
                confidence            = $confidence
                confidence_percentage = [math]::Round($confidence * 100, 2)
            }
        }
        #######################################################################
    }

    process {

        try {

            # expand and validate the image path
            $imagePath = GenXdev.FileSystem\Expand-Path $ImagePath

            Microsoft.PowerShell.Utility\Write-Verbose `
                "Processing image: $imagePath"

            # validate that the file is a valid image
            $null = GenXdev.AI\Test-DeepLinkImageFile -Path $imagePath

            # construct the api endpoint uri for deepstack scene recognition
            $uri = "$($script:ApiBaseUrl)/v1/vision/scene"

            Microsoft.PowerShell.Utility\Write-Verbose "Sending request to: $uri"

            # Validate image file exists before processing
            if (-not [System.IO.File]::Exists($imagePath)) {
                Microsoft.PowerShell.Utility\Write-Warning "Image file not found: $imagePath"
                return @{
                    success = $false
                    error = "No valid image file found"
                    duration = 0
                } | Microsoft.PowerShell.Utility\ConvertTo-Json
            }

            # create form data for deepstack api (it expects multipart form data)
            $form = @{
                image = Microsoft.PowerShell.Management\Get-Item -LiteralPath $imagePath
            }

            # send the request to the deepstack scene recognition api
            Microsoft.PowerShell.Utility\Write-Verbose `
                'Sending image data to DeepStack scene recognition API'

            $response = Microsoft.PowerShell.Utility\Invoke-RestMethod `
                -Verbose:$false `
                -ProgressAction Continue `
                -Uri $uri `
                -Method Post `
                -Form $form `
                -TimeoutSec 30 `
                -ErrorAction Stop

            Microsoft.PowerShell.Utility\Write-Verbose `
            ('API Response: ' +
                "$($response |
                    Microsoft.PowerShell.Utility\ConvertTo-Json -Depth 3)")

            # process the response from deepstack
            $sceneResult = Format-SceneResult -SceneData $response

            Microsoft.PowerShell.Utility\Write-Output $sceneResult

        }
        catch [System.Net.WebException] {

            Microsoft.PowerShell.Utility\Write-Warning `
                "Network error during scene recognition: $_"
        }
        catch [System.TimeoutException] {

            Microsoft.PowerShell.Utility\Write-Warning `
                "Timeout during scene recognition for $imagePath"
        }
        catch {
            # Check if this is a file access issue vs actual processing failure
            if ($_.Exception.Message -like "*Could not find item*" -or
                $_.Exception.Message -like "*No valid image file found*") {

                Microsoft.PowerShell.Utility\Write-Verbose `
                    "Scene detection skipped - file not accessible: $imagePath"
            }
            else {
                Microsoft.PowerShell.Utility\Write-Warning `
                    "Scene detection failed for $imagePath`: $($_.Exception.Message)"
            }
        }
    }

    end {

        # no cleanup required for this function
    }
}