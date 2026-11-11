part of 'teams_screen.dart';

extension _EmptyTeamsPresentation on _TeamsScreenState {
  Widget _emptyTeams(BuildContext context, bool es) {
    return Center(
        child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.groups_outlined,
                  size: 64, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 16),
              Text(
                  es
                      ? 'Tu próximo equipo empieza aquí'
                      : 'Your next team starts here',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              Text(
                  es
                      ? 'Crea varios equipos, elige hasta 6 Pokémon y revisa sus debilidades.'
                      : 'Create multiple teams, choose up to 6 Pokémon and review their weaknesses.',
                  textAlign: TextAlign.center),
            ])));
  }
}
