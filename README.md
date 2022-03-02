# NtqImporter

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/ntq_importer`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ntq_importer'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install ntq_importer

## Usage

    Pour générer un nouvel importeur, lancez la commande suivante:
    ```ruby
    ntq_importer:importer --name nom_de_mon_importeur
    ```

    Il sera alors créé un dossier ntq_importers dans /lib, contenant votre importeur, ainsi que d'un fichier application_importer.rb

    Décrivez dans un premier temps les headers grâce à au schema (@headers_schema)

    Voici la liste des propriétés possibles de renseigner pour chaque schema de header :
    - name: string | regexp # valeur du header dans votre fichier
    - sheet_name: string | regexp | nil # nom de la feuille où se situe votre header, s'il s'agit d'un fichier de type spreadsheet
    - required: boolean # est-ce que le header est requis
    - data_direction: HEADER_DATA_DIRECTION_BOTTOM # sens dans lequel l'importeur doit récupérer les données par rapport au header
    - data_type: HEADER_DATA_TYPE_ANY | HEADER_DATA_TYPE_NUMERIC # type des données attendues
    - data_required: boolean # est-ce que les données sont requises (pas de données vides)
    - line_index: int | nil # index de la ligne où se situe le header, si vous le connaissez
    - column_index: int | nil # index de la colonne où se situe le header, si vous le connaissez

    Un fois le schéma de vos headers défini, vous n'avez plus qu'à instancier votre importeur comme ceci:
    ```ruby
    mon_importeur = NtqImporters::NomDeMonImporteurImporter.new(file)
    ```
    Vous devez donner le fichier uploadé pour l'instanciation (attachment_data)

    Lancez mon_importeur.parse pour avoir accès à @parsed_data (mon_importeur.parsed_data) si besoin
    @parsed_data a le format suivant :

    {
        lines,
        sheets: [
            {
                name
                lines
            },
            ...
        ]
    }
    
    Puis, s'il n'y a pas d'erreurs, lancez mon_importeur.analyze, qui vous donnera @analyzed_data (mon_importeur.analyzed_data)

    @analyzed_data a le format suivant : 

    {
        logs,
        headers: [{
            logs,
            schema: {
                name,
                sheet_name,
                required,
                data_direction,
                data_type,
                data_required,
                line_index,
                column_index
            },
            header: {
                name
                sheet_name
                line_index,
                column_index
            },
            data: [{
                logs,
                content,
                line_index,
                column_index
            }]	
        }]
    }

    Il ne vous reste plus qu'à écrire votre logique d'import dans la fonction import prévue à cet effet, en utilisant @analyzed_data et @parsed_data si besoin


## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/ntq_importer.
