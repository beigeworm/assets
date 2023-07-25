function Get-RandomName {
    $numbers = 0..9999
    $adjectives = @(
        'Green', 'Happy', 'Small', 'Big', 'Fast', 'Slow', 'Smart', 'Clever', 'Bright', 'Dark',
        'Brave', 'Calm', 'Charming', 'Eager', 'Fierce', 'Gentle', 'Honest', 'Lucky', 'Proud', 'Shy',
        'Wise', 'Wild', 'Zealous', 'Adventurous', 'Ambitious', 'Cheerful', 'Curious', 'Energetic', 'Friendly', 'Graceful',
        'Handsome', 'Jolly', 'Kind', 'Nimble', 'Polite', 'Quirky', 'Silly', 'Thoughtful', 'Victorious', 'Witty',
        'Zesty', 'Bashful', 'Diligent', 'Joyful', 'Glamorous', 'Sincere', 'Modest', 'Optimistic', 'Glorious', 'Crazy'
    )

    $nouns = @(
        'Dog', 'Cat', 'Bird', 'Car', 'House', 'Tree', 'Book', 'Chair', 'Lamp', 'Table',
        'River', 'Mountain', 'Ocean', 'Star', 'Cloud', 'Rainbow', 'Moon', 'Sun', 'Bridge', 'Castle',
        'Island', 'Garden', 'Road', 'Forest', 'Desert', 'Beach', 'Lake', 'Ship', 'Train', 'Plane',
        'Robot', 'Dragon', 'Wizard', 'Ninja', 'Pirate', 'Knight', 'Princess', 'King', 'Queen', 'Alien',
        'Dinosaur', 'Unicorn', 'Mermaid', 'Superhero', 'Vampire', 'Werewolf', 'Ghost', 'Zombie', 'Witch', 'Fairy'
    )
    $randomAdjective = Get-Random -InputObject $adjectives
    $randomNoun = Get-Random -InputObject $nouns
    $randomNumber = Get-Random -Minimum 0 -Maximum 10000
    $paddedNumber = '{0:d4}' -f $randomNumber

    return "$paddedNumber-$randomAdjective-$randomNoun"
}

function Get-RandomFileExtension {
    $fileExtensions = @('.txt', '.docx', '.xlsx', '.pptx', '.pdf', '.jpg', '.png', '.mp3', '.mp4', '.zip')
    return Get-Random -InputObject $fileExtensions
}

# Set the root folder name
$rootFolderName = (Get-RandomName)

# Create the root folder
New-Item -ItemType Directory -Path $rootFolderName -Force | Out-Null

# Create 20 subfolders
for ($i = 1; $i -le 25; $i++) {
    $subFolderName = Join-Path -Path $rootFolderName -ChildPath (Get-RandomName)
    New-Item -ItemType Directory -Path $subFolderName -Force | Out-Null

    $fileCount = Get-Random -Minimum 20 -Maximum 100
    for ($j = 1; $j -le $fileCount; $j++) {
        $fileName = Join-Path -Path $subFolderName -ChildPath ((Get-RandomName) + (Get-RandomFileExtension))
        New-Item -ItemType File -Path $fileName -Force | Out-Null
    }
}

Write-Host "Random folders and files have been created successfully."
