import FirebaseFirestore
import SwiftUI

struct DailyActivitiesView: View {
    let assignments: [AssignedExerciseDetail]
    let categories: [ActivityCategory]
    let isLoading: Bool
    let onSeeAll: () -> Void
    let onExerciseSelected: (String) -> Void  // ID

    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.2))
                            .frame(width: 40, height: 40)

                        Image(systemName: "calendar")
                            .foregroundColor(.white)
                            .font(.system(size: 20))
                    }

                    Text("Today's Activities")
                        .font(.theme.title3)
                        .foregroundColor(.white)
                }

                Spacer()

                Button(action: onSeeAll) {
                    HStack(spacing: 4) {
                        Text("See all")
                            .font(.theme.subheadline)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .bold))
                    }
                    .foregroundColor(.white.opacity(0.9))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.white.opacity(0.15))
                    .cornerRadius(20)
                }
            }
            .padding(20)
            .background(
                LinearGradient(
                    colors: [
                        Color.theme.primary,
                        Color.theme.primary.opacity(0.8),
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(24)
            .shadow(color: Color.theme.primary.opacity(0.3), radius: 10, x: 0, y: 5)

            // Activities List
            VStack(spacing: 16) {
                if isLoading {
                    ProgressView("Loading activities...")
                        .frame(maxWidth: .infinity, minHeight: 100)
                } else if assignments.isEmpty {
                    // Empty State
                    VStack(spacing: 12) {
                        Image(systemName: "moon.stars.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.gray.opacity(0.5))
                        Text("No activities for today")
                            .font(.theme.body)
                            .foregroundColor(.gray)
                        Text("Check your subscriptions if you want daily exercises.")
                            .font(.theme.caption)
                            .foregroundColor(.gray.opacity(0.8))
                    }
                    .padding(.vertical, 30)
                } else {
                    ForEach(assignments) { assignment in
                        // Find category image if available
                        let categoryImage = categories.first(where: {
                            $0.id == assignment.exercise.categoryId
                        })?.imageUrl

                        DailyActivityRow(
                            assignment: assignment,
                            categoryImageUrl: categoryImage,
                            onTap: { onExerciseSelected(assignment.exercise.id ?? "") }
                        )
                    }
                }
            }
            .padding(.horizontal, 4)
        }
    }
}

struct DailyActivityRow: View {
    let assignment: AssignedExerciseDetail
    let categoryImageUrl: String?
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Icon/Image
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.theme.surface)
                        .frame(width: 56, height: 56)

                    if let urlString = categoryImageUrl, let url = URL(string: urlString),
                        !urlString.isEmpty
                    {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        } placeholder: {
                            Image(systemName: "figure.mind.and.body")
                                .font(.system(size: 24))
                                .foregroundColor(Color.theme.primary)
                        }
                        .frame(width: 32, height: 32)
                    } else {
                        Image(systemName: "figure.mind.and.body")
                            .font(.system(size: 24))
                            .foregroundColor(Color.theme.primary)
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(assignment.exercise.getTitle())
                        .font(.theme.headline)
                        .foregroundColor(Color.theme.text)

                    HStack(spacing: 8) {
                        Label {
                            Text("\(assignment.exercise.durationMinutes) min")
                                .font(.theme.footnote)
                        } icon: {
                            Image(systemName: "clock")
                                .font(.system(size: 12))
                        }
                        .foregroundColor(Color.theme.textSecondary)
                    }
                }

                Spacer()

                // Status Indicator
                ZStack {
                    Circle()
                        .stroke(
                            assignment.completed ? Color.theme.success : Color.theme.border,
                            lineWidth: 2
                        )
                        .frame(width: 28, height: 28)

                    if assignment.completed {
                        Circle()
                            .fill(Color.theme.success)
                            .frame(width: 18, height: 18)
                        Image(systemName: "checkmark")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }
            .padding(16)
            .background(Color.theme.card)
            .cornerRadius(20)
            .shadow(
                color: assignment.completed
                    ? Color.theme.success.opacity(0.1) : Color.theme.shadow.opacity(0.02),
                radius: 5, x: 0, y: 2
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
