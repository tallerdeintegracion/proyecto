# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160502223708) do

  create_table "formulas", force: :cascade do |t|
    t.string   "sku",               limit: 255
    t.string   "descripcion",       limit: 255
    t.integer  "lote",              limit: 4
    t.integer  "unidad",            limit: 4
    t.string   "skuIngerdiente",    limit: 255
    t.string   "ingrediente",       limit: 255
    t.integer  "requerimiento",     limit: 4
    t.integer  "unidadIngrediente", limit: 4
    t.integer  "precioIngrediente", limit: 4
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  create_table "ocs", force: :cascade do |t|
    t.string   "oc",         limit: 255
    t.string   "estados",    limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "precios", force: :cascade do |t|
    t.string   "sku",            limit: 255
    t.string   "descripcion",    limit: 255
    t.integer  "precioUnitario", limit: 4
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  create_table "productions", force: :cascade do |t|
    t.string   "sku",        limit: 255
    t.integer  "cantidad",   limit: 4
    t.datetime "disponible"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "sent_orders", force: :cascade do |t|
    t.string   "oc",         limit: 255
    t.string   "sku",        limit: 255
    t.integer  "cantidad",   limit: 4
    t.string   "estado",     limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "skus", force: :cascade do |t|
    t.string   "sku",              limit: 255
    t.string   "descripcion",      limit: 255
    t.string   "tipo",             limit: 255
    t.string   "grupoProyecto",    limit: 255
    t.string   "unidades",         limit: 255
    t.integer  "costoUnitario",    limit: 4
    t.integer  "loteProduccion",   limit: 4
    t.float    "tiempoProduccion", limit: 24
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

end
