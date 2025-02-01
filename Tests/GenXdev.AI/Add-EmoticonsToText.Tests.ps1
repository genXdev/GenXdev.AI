################################################################################

BeforeAll {

}

################################################################################
Describe "Add-EmoticonsToText" {

    It "Should use custom instructions" {
        $result = Add-EmoticonsToText -Text "Standard smileyface" -Instructions "Return the emoji requested"
        $result | Should -BeLike "*😊*"
    }
}
################################################################################
