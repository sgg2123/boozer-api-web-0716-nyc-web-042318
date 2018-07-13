module Api
  module V1
    class CocktailsController < ApplicationController
      def index
        render json: Cocktail.all.sort_by{|c| c.name.downcase.split(//).map{|letter| letter.unicode_normalize(:nfkd).chars[0]}.join().downcase}
      end

      def show
        cocktail = Cocktail.find(params[:id])

        cocktail_json = {
          id: cocktail.id,
          name: cocktail.name,
          description: cocktail.description,
          instructions: cocktail.instructions,
          source: cocktail.source,
          proportions: cocktail.proportions.map do |prop|
            {
              id: prop.id,
              ingredient_name: prop.ingredient.name,
              amount: prop.amount
            }
          end
        }

        render json: cocktail_json
      end

      def create
        if Cocktail.find_by(name: cocktail_params[:name])
          render json: {error: 'That cocktail already exists'}
        else
          cocktail = Cocktail.create(cocktail_params)
          if cocktail.errors.full_messages.length > 0
            render json: {error: cocktail.errors.full_messages.map {|m| m.gsub(',', '') + '. '}.join()}
          else
            render json: cocktail
          end
        end
      end

      def edit

      end

      def update
        cocktail = Cocktail.find(params[:id])
        cocktail_params[:proportions].map do |prop|
          if Ingredient.find_by(name: prop['ingredient_name'])
            ingredient = Ingredient.find_by(name: prop['ingredient_name'])
            cocktail.ingredients << ingredient
            prop_id = cocktail.proportions.last.id
            proportion = Proportion.find(prop_id)
            proportion.update(amount: prop['amount'])
          else
            new_i = Ingredient.create({name: prop['ingredient_name']})
            cocktail.ingredients << new_i
            prop_id = cocktail.proportions.last.id
            proportion = Proportion.find(prop_id)
            proportion.update(amount: prop['amount'])
          end
        end
      end

      def destroy

      end

      private
      def cocktail_params
        params.permit(:id, :name, :description, :instructions, :source, proportions: [:id, :ingredient_name, :amount])
      end
    end
  end
end
