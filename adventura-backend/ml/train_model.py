import recommendation_model

print("🔄 Running scheduled model retraining...")
recommendation_model.train_als_model()
print("✅ Model retrained successfully via cron job.")
