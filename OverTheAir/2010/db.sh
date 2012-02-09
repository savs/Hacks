#!/bin/bash
psql < OTA_destroydb.sql
psql < OTA_createdb.sql
psql < OTA_createtables.sql
